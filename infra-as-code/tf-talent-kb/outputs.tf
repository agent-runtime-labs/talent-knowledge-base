output "bedrock_kb_id" {
  value = aws_bedrockagent_knowledge_base.main.id
}
output "bedrock_kb_data_source_id" {
  value = aws_bedrockagent_data_source.candidate_profiles.data_source_id
}