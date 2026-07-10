module "bedrock_kb_sync" {
  source            = "../tf-modules/aws/bedrock-kb-sync"
  function_name     = format("%s-bedrock-kb-sync", local.resource_name_prefix)
  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id
  data_source_id    = aws_bedrockagent_data_source.candidate_profiles.data_source_id
  depends_on = [
    aws_bedrockagent_data_source.candidate_profiles
  ]
}