module "s3_source_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = format("%s-%s", local.resource_name_prefix, local.s3_bucket_name_suffix)

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "s3_stage_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = format("%s-%s", local.resource_name_prefix, local.s3_multimodal_stage_bucket_name_suffix)
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true


}

resource "aws_s3vectors_vector_bucket" "s3_vectror" {
  vector_bucket_name = format("%s-%s", local.resource_name_prefix, local.s3_vectors_bucket_name_suffix)
}

resource "aws_s3vectors_index" "main" {
  for_each = { for idx in local.s3_vectors_indices : idx.name => idx }

  index_name         = each.value.name
  vector_bucket_name = aws_s3vectors_vector_bucket.s3_vectror.vector_bucket_name

  data_type       = each.value.data_type
  dimension       = each.value.dimension
  distance_metric = each.value.distance_metric
  metadata_configuration {
    non_filterable_metadata_keys = each.value.metadata_configuration.non_filterable_metadata_keys
  }
}