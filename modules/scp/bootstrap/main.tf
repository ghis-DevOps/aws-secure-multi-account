terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "landing-zone"
}

# 1. KMS Key for State File Encryption
resource "aws_kms_key" "terraform_state_key" {
  description             = "KMS Key for Terraform State Storage"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. S3 Bucket for Remote State
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "org-tfstate-${var.environment}-management"
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Enforce Bucket Versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce Server-Side KMS Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block all public access to the state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "org-tfstate-locks-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state_key.arn
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Name of the S3 state bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.id
  description = "Name of the DynamoDB state locking table"
}

output "kms_key_arn" {
  value       = aws_kms_key.terraform_state_key.arn
  description = "ARN of the KMS Key used for state encryption"
}

output "iam_policy_arn" {
  value       = aws_iam_policy.github_actions_policy.arn
  description = "ARN of the IAM policy to attach to your GitHub Actions OIDC role"
}