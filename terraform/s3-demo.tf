# ============================================================
# SECURITY LAB ONLY
#
# Deliberately public S3 bucket containing ONLY synthetic data.
# NEVER store real credentials, PII or customer data here.
# ============================================================

resource "aws_s3_bucket" "demo_sensitive_data" {
  bucket = "${var.project_name}-sensitive-data-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name           = "${var.project_name}-sensitive-data"
    Project        = var.project_name
    Environment    = "security-lab"
    Classification = "CONFIDENTIAL-DEMO"
    ManagedBy      = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "demo_sensitive_data" {
  bucket = aws_s3_bucket.demo_sensitive_data.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "demo_sensitive_data" {
  bucket = aws_s3_bucket.demo_sensitive_data.id

  depends_on = [
    aws_s3_bucket_public_access_block.demo_sensitive_data
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicListBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.demo_sensitive_data.arn
      },
      {
        Sid       = "PublicReadObjects"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.demo_sensitive_data.arn}/*"
      }
    ]
  })
}
