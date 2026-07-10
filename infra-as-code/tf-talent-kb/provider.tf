terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }
  backend "s3" {
    encrypt = true
  }
}


# The default AWS Provider
provider "aws" {
  region = var.resource_region
  default_tags {
    tags = var.default_tags
  }
}