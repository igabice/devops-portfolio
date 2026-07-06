data "aws_iam_policy_document" "static_assets" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.environment}-${var.bucket_name}-static-assets"

  tags = merge(var.tags, {
    Name        = "${var.environment}-static-assets"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_algorithm
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_policy" "static_assets" {
  count  = var.attach_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.static_assets.id
  policy = var.bucket_policy != null ? var.bucket_policy : data.aws_iam_policy_document.static_assets.json
}
