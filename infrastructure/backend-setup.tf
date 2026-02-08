# Backend Setup - Create S3 and DynamoDB for Terraform State Management
# Run this ONLY ONCE before main infrastructure deployment
# Comment out after first run or use a separate state backend

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "eaglewings-bank-terraform-state-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "eaglewings-bank-terraform-state"
  }
}

# Enable versioning on S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption on S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for Terraform Locks
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "eaglewings-bank-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "eaglewings-bank-terraform-locks"
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Outputs for backend setup
output "terraform_state_bucket" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "S3 bucket for Terraform state"
}

output "terraform_locks_table" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table for Terraform locks"
}
