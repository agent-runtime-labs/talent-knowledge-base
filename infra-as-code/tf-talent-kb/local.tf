data "aws_caller_identity" "current" {}

locals {
    aws_account_id = data.aws_caller_identity.current.account_id
    resource_name_prefix = format("%s-%s-%s-%s", local.aws_account_id, var.env, var.resource_region_short, var.project_name)
    s3_bucket_name_suffix = "kb-data"
    s3_multimodal_stage_bucket_name_suffix = "kb-stage"
}