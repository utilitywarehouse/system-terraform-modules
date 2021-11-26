resource "aws_s3_bucket" "bucket" {
  bucket = local.prefixed_name
  acl    = var.public ? "public-read" : "private"

  # Ensure that bucket is encrypted at rest
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Expiration of bucket objects
  lifecycle_rule {
    id      = "object-expiration"
    enabled = var.object_expiration

    expiration {
      days = var.object_expiration_days
    }
  }

  # Enable versioning
  versioning {
    enabled = var.versioning
  }

  # Expiration of old versions of the objects
  lifecycle_rule {
    id      = "version-expiration"
    enabled = var.version_expiration

    noncurrent_version_expiration {
      days = var.version_expiration_days
    }
  }

  # tags help with cost allocation
  tags = {
    Name  = local.prefixed_name
    owner = local.caller_team
  }
}

# If bucket is private, block public access to comply with security audits
resource "aws_s3_bucket_public_access_block" "bucket" {
  count  = var.public ? 0 : 1
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
}

output "bucket" {
  value = {
    id = aws_s3_bucket.bucket.id
  }
}
