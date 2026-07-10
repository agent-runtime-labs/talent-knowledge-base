# Variables for Bedrock KB Sync Lambda Module

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "bedrock-kb-sync"
}

variable "knowledge_base_id" {
  description = "AWS Bedrock Knowledge Base ID"
  type        = string
}

variable "data_source_id" {
  description = "AWS Bedrock Knowledge Base Data Source ID"
  type        = string
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 60
  validation {
    condition     = var.timeout >= 3 && var.timeout <= 900
    error_message = "Timeout must be between 3 and 900 seconds"
  }
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240 MB"
  }
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "enable_s3_trigger" {
  description = "Whether to enable S3 trigger for the Lambda function"
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket that will trigger the Lambda (required if enable_s3_trigger is true)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
