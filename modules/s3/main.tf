# modules/s3/main.tf
# Advanced S3 Module with OAC, Lifecycle and Website support

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = merge({ Name = var.bucket_name, Environment = var.environment }, var.tags)
}

# 1. Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# 2. Encryption (Secure by Default)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

# 3. Public Access Block (Elite Security)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Website Hosting (Optional)
resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.enable_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.this.id
  index_document { suffix = var.index_document }
}

# 5. CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.allowed_origins) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# 6. Lifecycle Management (Cost Optimization)
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  # Always clean up incomplete uploads
  rule {
    id     = "cleanup-incomplete-multipart-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
  }

  # Transition to IA
  dynamic "rule" {
    for_each = var.transition_to_ia_days != null ? [1] : []
    content {
      id     = "transition-to-ia"
      status = "Enabled"
      filter {}
      transition {
        days          = var.transition_to_ia_days
        storage_class = "STANDARD_IA"
      }
    }
  }

  # Transition to Glacier
  dynamic "rule" {
    for_each = var.transition_to_glacier_days != null ? [1] : []
    content {
      id     = "transition-to-glacier"
      status = "Enabled"
      filter {}
      transition {
        days          = var.transition_to_glacier_days
        storage_class = "GLACIER"
      }
    }
  }

  # Cleanup old versions
  dynamic "rule" {
    for_each = var.enable_versioning ? [1] : []
    content {
      id     = "cleanup-old-versions"
      status = "Enabled"
      filter {}
      noncurrent_version_expiration { noncurrent_days = var.old_version_expiration_days }
    }
  }
}

# 7. Smart Policy Management (OAC + Custom)
data "aws_iam_policy_document" "combined" {
  source_policy_documents = var.bucket_policy != null ? [var.bucket_policy] : []

  # Auto-allow CloudFront OAC access
  dynamic "statement" {
    for_each = var.cloudfront_distribution_arn != null ? [1] : []
    content {
      actions   = ["s3:GetObject"]
      resources = ["${aws_s3_bucket.this.arn}/*"]
      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.cloudfront_distribution_arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  # cloudfront_distribution_arn is intentionally excluded from count: it is a computed
  # value (unknown at plan time) and would break Terraform plan. Use enable_oac_policy=true
  # whenever cloudfront_distribution_arn comes from another module in the same stack.
  count  = (var.enable_oac_policy || var.bucket_policy != null) ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.combined.json
}
