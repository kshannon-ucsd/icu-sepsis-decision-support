terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
  # No remote backend — local state is free
}

provider "aws" {
  region = var.aws_region
}

# ─── S3 Bucket ───────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "shared" {
  bucket = var.bucket_name

  # Do not auto-delete on destroy so data is not lost accidentally
  force_destroy = false

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Block all public access — collaborators use IAM credentials only
resource "aws_s3_bucket_public_access_block" "shared" {
  bucket = aws_s3_bucket.shared.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disable ACLs — ownership is enforced to bucket owner (simplest & most secure)
resource "aws_s3_bucket_ownership_controls" "shared" {
  bucket = aws_s3_bucket.shared.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# SSE-S3 (AES256) — built-in encryption at no extra cost
# (SSE-KMS would cost $0.03 per 10,000 API calls)
resource "aws_s3_bucket_server_side_encryption_configuration" "shared" {
  bucket = aws_s3_bucket.shared.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}
