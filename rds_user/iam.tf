locals {
  # arn looks like arn:aws:rds:eu-west-1:950135041896:db:dev-enablement-rds
  region                = split(":", var.db_instance.arn)[3]
  default_iam_role_name = "${var.db_instance.identifier}-${var.name}"
}

# Creates an IAM role that can be assumed through Vault that has the privilege to connect to the RDS instance.
data "aws_iam_policy_document" "vault_auth" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:user/sys-vault-credentials-provider",
        "arn:aws:iam::${var.account_id}:user/sys-vault-credentials-provider-gcp",
        "arn:aws:iam::${var.account_id}:user/sys-vault-credentials-provider-merit",
      ]
    }
  }
}

/*  do not create another role if an existing one was passed in. */
resource "aws_iam_role" "iam_access_role" {
  count                = var.existing_iam_role == null ? 1 : 0
  name                 = local.default_iam_role_name
  assume_role_policy   = data.aws_iam_policy_document.vault_auth.json
  permissions_boundary = "arn:aws:iam::${var.account_id}:policy/sys-${var.team}-boundary"
}


resource "aws_iam_role_policy" "access_role_policy" {
  name   = "${var.db_instance.identifier}-${var.name}"
  role   = var.existing_iam_role == null ? local.default_iam_role_name : var.existing_iam_role
  policy = data.aws_iam_policy_document.rds_policy_doc.json
}

data "aws_iam_policy_document" "rds_policy_doc" {
  statement {
    actions = [
      "rds-db:connect",
    ]

    resources = [
      "arn:aws:rds-db:${local.region}:${var.account_id}:dbuser:${var.db_instance.id}/${var.name}"
    ]
  }
}

output "iam_access_role" {
  value = {
    name = var.existing_iam_role == null ? aws_iam_role.iam_access_role[0].name : var.existing_iam_role
    arn  = var.existing_iam_role == null ? aws_iam_role.iam_access_role[0].arn : "use the arn of the existing role"
  }
}
