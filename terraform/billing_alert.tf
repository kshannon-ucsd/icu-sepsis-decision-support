# ─── S3 Cost Alert ───────────────────────────────────────────────────────────
#
# Uses AWS Budgets (free for up to 2 budgets per account) to monitor S3 spend.
# The cost filter targets the entire Amazon S3 service on your account.
#
# NOTE: For per-bucket filtering you would also need to activate the
# "ManagedBy" tag as a Cost Allocation Tag in the AWS Billing console
# (Billing → Cost allocation tags → Activate). The service-level filter
# below works with zero extra setup.

resource "aws_budgets_budget" "s3_cost_alert" {
  name         = "${var.bucket_name}-cost-alert"
  budget_type  = "COST"
  limit_amount = "10"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Scope to Amazon S3 only (not your whole AWS bill)
  cost_filter {
    name   = "Service"
    values = ["Amazon Simple Storage Service"]
  }

  # Alert at 80% ($8) — early warning before the limit is hit
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # Alert at 100% ($10) — limit reached
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
