# ─── IAM Users ───────────────────────────────────────────────────────────────

resource "aws_iam_user" "friends" {
  for_each = toset(var.friends)

  name = each.key

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ─── Shared Read/Write Policy ─────────────────────────────────────────────────

data "aws_iam_policy_document" "s3_read_write" {
  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.shared.arn,
    ]
  }

  statement {
    sid    = "ReadWriteObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.shared.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_read_write" {
  name        = "${var.bucket_name}-read-write"
  description = "Read and write access to the ${var.bucket_name} S3 bucket"
  policy      = data.aws_iam_policy_document.s3_read_write.json
}

# ─── Attach Policy to Each Friend ────────────────────────────────────────────

resource "aws_iam_user_policy_attachment" "friends" {
  for_each = toset(var.friends)

  user       = aws_iam_user.friends[each.key].name
  policy_arn = aws_iam_policy.s3_read_write.arn
}

# ─── Access Keys (credentials to share with each friend) ─────────────────────

resource "aws_iam_access_key" "friends" {
  for_each = toset(var.friends)

  user = aws_iam_user.friends[each.key].name
}
