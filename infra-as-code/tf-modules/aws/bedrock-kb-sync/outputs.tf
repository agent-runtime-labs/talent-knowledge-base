# Outputs for Bedrock KB Sync Lambda Module

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.bedrock_kb_sync.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.bedrock_kb_sync.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function (for API Gateway, etc.)"
  value       = aws_lambda_function.bedrock_kb_sync.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_role.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.arn
}

output "knowledge_base_id" {
  description = "Knowledge Base ID configured for this function"
  value       = var.knowledge_base_id
}

output "data_source_id" {
  description = "Data Source ID configured for this function"
  value       = var.data_source_id
}
