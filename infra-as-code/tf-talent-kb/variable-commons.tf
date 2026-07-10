variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "project_name_short" {
  type = string
}

variable "resource_region" {
  type        = string
  description = "AWS Region in which you want to create resources"
}

variable "resource_region_short" {
  type        = string
  description = "Short name of the AWS Region in which you want to create resources"
}

variable "default_tags" {
  description = "Default set of tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}