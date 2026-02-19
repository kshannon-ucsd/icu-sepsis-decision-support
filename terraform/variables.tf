variable "aws_region" {
  description = "AWS region to deploy resources (us-east-1 is cheapest for S3)"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique name for the S3 bucket"
  type        = string
}

variable "friends" {
  description = "List of IAM usernames to create (one per collaborator)"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment tag applied to all resources"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address to receive billing alerts when S3 costs exceed $10/month"
  type        = string
}
