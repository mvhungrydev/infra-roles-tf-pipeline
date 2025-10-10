# Main Terraform configuration for AWS IAM roles for CodeBuild and CodePipeline

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # S3 Backend Configuration (uncomment and configure after initial deployment)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "iam-roles/terraform.tfstate"
  #   region = "us-east-1"
  #   # Note: No DynamoDB table for locking as requested
  # }
}

provider "aws" {
  region = var.aws_region
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}