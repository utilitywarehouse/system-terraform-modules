data "aws_iam_policy_document" "ro" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_id}",
      "arn:aws:s3:::${var.bucket_id}/*",
    ]
  }
}

data "aws_iam_policy_document" "rw" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_id}",
      "arn:aws:s3:::${var.bucket_id}/*",
    ]
  }
}
