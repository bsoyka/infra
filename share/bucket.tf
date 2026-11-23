# Private bucket for temporary shared files. Nothing is public at the bucket
# level: reads go through CloudFront (cdn.tf), writes come only from the
# per-client IAM users (uploaders.tf).

resource "aws_s3_bucket" "share" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "share" {
  bucket = aws_s3_bucket.share.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ACLs off entirely; the bucket owner owns every object.
resource "aws_s3_bucket_ownership_controls" "share" {
  bucket = aws_s3_bucket.share.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "share" {
  bucket = aws_s3_bucket.share.id

  dynamic "rule" {
    for_each = local.prefixes

    content {
      id     = "expire-${rule.key}"
      status = "Enabled"

      filter {
        prefix = rule.value.path
      }

      expiration {
        days = rule.value.expire_days
      }
    }
  }

  # Abandoned multipart uploads (large attachments that failed partway) get
  # cleaned up too. Nothing can be written outside the prefixes above: the
  # uploader policies don't allow it.
  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# Only this CloudFront distribution may read objects.
data "aws_iam_policy_document" "share_bucket" {
  statement {
    sid       = "CloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.share.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.share.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "share" {
  bucket = aws_s3_bucket.share.id
  policy = data.aws_iam_policy_document.share_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.share]
}
