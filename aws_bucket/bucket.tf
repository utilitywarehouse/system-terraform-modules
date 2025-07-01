resource "aws_s3_bucket" "bucket" {
  bucket = local.prefixed_name

  # tags help with cost allocation
  tags = {
    Name  = local.prefixed_name
    owner = var.team
  }
}

# AWS disabled s3 buckets ACLs:
# https://aws.amazon.com/about-aws/whats-new/2022/12/amazon-s3-automatically-enable-block-public-access-disable-access-control-lists-buckets-april-2023/
# We need to enable this manually and se object ownership. See:
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest#private-bucket-with-versioning-enabled
# https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/issues/223#issuecomment-1545649581
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.public ? "public-read" : "private"

  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]
}

# If bucket is private, block public access to comply with security audits
resource "aws_s3_bucket_public_access_block" "bucket" {
  count  = var.public ? 0 : 1
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.version_expiration || var.object_expiration ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  # Expiration of bucket objects
  dynamic "rule" {
    for_each = var.object_expiration ? [1] : []
    content {
      id     = "object-expiration"
      status = "Enabled"

      expiration {
        days = var.object_expiration_days
      }
    }
  }

  # Expiration of old versions of the objects
  dynamic "rule" {
    for_each = var.version_expiration ? [1] : []
    content {
      id     = "version-expiration"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = var.version_expiration_days
      }
    }
  }

  # Default to Intelligent-Tiering
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/intelligent-tiering-overview.html
  rule {
    id     = "default-to-intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

output "bucket" {
  value = {
    id = aws_s3_bucket.bucket.id
    arn = aws_s3_bucket.bucket.arn
  }
}
