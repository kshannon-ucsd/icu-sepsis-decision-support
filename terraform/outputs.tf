output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.shared.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.shared.arn
}

output "bucket_region" {
  description = "AWS region where the bucket lives"
  value       = aws_s3_bucket.shared.region
}

# Sensitive: contains secret access keys — retrieve with:
#   terraform output -json friend_access_keys
output "friend_access_keys" {
  description = "AWS access key pairs for each friend — distribute securely"
  sensitive   = true
  value = {
    for username in var.friends : username => {
      access_key_id     = aws_iam_access_key.friends[username].id
      secret_access_key = aws_iam_access_key.friends[username].secret
    }
  }
}
