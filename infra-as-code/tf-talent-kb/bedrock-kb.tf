data "aws_iam_policy_document" "bedrock_knowledge_base_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bedrock_knowledge_base" {
  statement {
    sid = "InvokeEmbeddingModel"

    actions = [
      "bedrock:InvokeModel"
    ]

    resources = [
      "arn:aws:bedrock:${var.resource_region}::foundation-model/amazon.titan-embed-text-v2:0"
    ]
  }

  statement {
    sid = "ListKnowledgeBaseSourceBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      module.s3_source_bucket.s3_bucket_arn
    ]
  }

  statement {
    sid = "ReadKnowledgeBaseSourceObjects"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.s3_source_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    sid = "ListKnowledgeBaseStageBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      module.s3_stage_bucket.s3_bucket_arn
    ]
  }

  statement {
    sid = "AccessKnowledgeBaseStageObjects"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${module.s3_stage_bucket.s3_bucket_arn}/*"
    ]
  }

  statement {
    sid = "AccessS3VectorsStore"

    actions = [
      "s3vectors:*"
    ]

    resources = [
      aws_s3vectors_vector_bucket.s3_vectror.vector_bucket_arn,
      aws_s3vectors_index.main[local.s3_vectors_indices[0].name].index_arn
    ]
  }
}

resource "aws_iam_role" "bedrock_knowledge_base" {
  name               = format("%s-bedrock-kb", local.resource_name_prefix)
  assume_role_policy = data.aws_iam_policy_document.bedrock_knowledge_base_assume_role.json
}

resource "aws_iam_role_policy" "bedrock_knowledge_base" {
  name   = format("%s-bedrock-kb", local.resource_name_prefix)
  role   = aws_iam_role.bedrock_knowledge_base.id
  policy = data.aws_iam_policy_document.bedrock_knowledge_base.json
}

resource "aws_bedrockagent_knowledge_base" "main" {
  name        = format("%s-kb", local.resource_name_prefix)
  description = "Talent knowledge base backed by S3 Vectors"
  role_arn    = aws_iam_role.bedrock_knowledge_base.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${var.resource_region}::foundation-model/amazon.titan-embed-text-v2:0"

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = local.s3_vectors_indices[0].dimension
          embedding_data_type = upper(local.s3_vectors_indices[0].data_type)
        }
      }

      supplemental_data_storage_configuration {
        storage_location {
          type = "S3"

          s3_location {
            uri = "s3://${module.s3_stage_bucket.s3_bucket_id}/"
          }
        }
      }
    }
  }

  storage_configuration {
    type = "S3_VECTORS"

    s3_vectors_configuration {
      index_arn = aws_s3vectors_index.main[local.s3_vectors_indices[0].name].index_arn
    }
  }

  depends_on = [aws_iam_role_policy.bedrock_knowledge_base]
}

resource "aws_bedrockagent_data_source" "candidate_profiles" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id
  name              = format("%s-candidate-profiles", local.resource_name_prefix)
  description       = "Candidate profile source data for Bedrock knowledge base ingestion"

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = module.s3_source_bucket.s3_bucket_arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"

      fixed_size_chunking_configuration {
        max_tokens         = 600
        overlap_percentage = 15
      }
    }
  }
}


# Store Knowledge Base IDs in SSM Parameter Store
resource "aws_ssm_parameter" "kb_id" {

  name        = "${local.ssm_param_prefix}/knowledge-base/${local.s3_vectors_indices[0].name}/id"
  description = "Bedrock Knowledge Base ID for ${local.s3_vectors_indices[0].name} in ${var.env}"
  type        = "String"
  value       = aws_bedrockagent_knowledge_base.main.id
  depends_on  = [aws_bedrockagent_knowledge_base.main]
}

# Store Data Source IDs in SSM Parameter Store
resource "aws_ssm_parameter" "ds_id" {

  name        = "${local.ssm_param_prefix}/knowledge-base/${local.s3_vectors_indices[0].name}/data-source-id"
  description = "Bedrock Data Source ID for ${local.s3_vectors_indices[0].name} in ${var.env}"
  type        = "String"
  value       = aws_bedrockagent_data_source.candidate_profiles.data_source_id

  depends_on = [aws_bedrockagent_data_source.candidate_profiles]
}
