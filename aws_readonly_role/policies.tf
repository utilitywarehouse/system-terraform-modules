/*
 * ReadOnlyAccess covers the control plane of every service, which is what
 * looking around an account needs, but it reads data too: s3:Get* on every
 * bucket, ssm:Get* on every parameter and dynamodb:Query/Scan on every table.
 * The denies below are what make the role safe to hand to a person or an
 * agent that is only meant to examine infrastructure.
 */

data "aws_iam_policy_document" "deny_data_reads" {
  # Every UW account keeps its terraform state in a uw-terraform bucket, and
  # terraform commands have to read those objects.
  statement {
    sid    = "TerraformStateObjectsOnly"
    effect = "Deny"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAttributes",
    ]

    not_resources = ["arn:aws:s3:::uw-terraform*/*"]
  }

  # Parameters hold connection strings and credentials, and the API does not
  # say which parameter is a secret before reading it.
  statement {
    sid    = "NoSsmParameterValues"
    effect = "Deny"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = ["*"]
  }

  # ReadOnlyAccess does not carry secretsmanager:GetSecretValue today. The
  # deny keeps a future revision of that policy from handing out secrets.
  statement {
    sid    = "NoSecretValues"
    effect = "Deny"

    actions = [
      "secretsmanager:BatchGetSecretValue",
      "secretsmanager:GetSecretValue",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "NoDynamodbItemReads"
    effect = "Deny"

    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:PartiQLSelect",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]

    resources = ["*"]
  }
}
