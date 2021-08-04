data "aws_iam_policy_document" "ro" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
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
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_id}",
      "arn:aws:s3:::${var.bucket_id}/*",
    ]
  }
}
