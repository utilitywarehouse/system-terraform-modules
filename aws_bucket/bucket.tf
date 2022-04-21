resource "aws_s3_bucket" "bucket" {
  bucket = local.prefixed_name

  # tags help with cost allocation
  tags = {
    Name  = local.prefixed_name
    owner = local.caller_team
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.public ? "public-read" : "private"
}

# If bucket is private, block public access to comply with security audits
resource "aws_s3_bucket_public_access_block" "bucket" {
  count  = var.public ? 0 : 1
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
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
}

output "bucket" {
  value = {
    id = aws_s3_bucket.bucket.id
  }
}
