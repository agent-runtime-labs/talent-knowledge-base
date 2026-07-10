data "aws_caller_identity" "current" {}

locals {
  aws_account_id                         = data.aws_caller_identity.current.account_id
  resource_name_prefix                   = format("%s-%s-%s-%s", local.aws_account_id, var.env, var.resource_region_short, var.project_name)
  ssm_param_prefix                       = format("/%s/%s", var.env, var.project_name)
  s3_bucket_name_suffix                  = "kb-data"
  s3_multimodal_stage_bucket_name_suffix = "kb-stage"
  s3_vectors_bucket_name_suffix          = "kb-vector"
  s3_vectors_indices = [{
    name            = "${var.project_name_short}-kb-vector-index",
    dimension       = 1024,
    distance_metric = "cosine",
    data_type       = "float32"
    kb_name         = "kb"
    # Refer https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html#:~:text=Expand%20the%20Additional,AMAZON_BEDROCK_METADATA%20as%20keys
    metadata_configuration = {
      non_filterable_metadata_keys = ["AMAZON_BEDROCK_TEXT", "AMAZON_BEDROCK_METADATA"]
    }
  }]
}