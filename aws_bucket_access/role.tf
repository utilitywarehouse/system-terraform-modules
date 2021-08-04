data "aws_iam_policy_document" "vault_auth" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.caller_account_id}:user/sys-vault-${var.exp_cluster ? "exp-1-" : ""}credentials-provider",
        "arn:aws:iam::${local.caller_account_id}:user/sys-vault-${var.exp_cluster ? "exp-1-" : ""}credentials-provider-gcp",
        "arn:aws:iam::${local.caller_account_id}:user/sys-vault-${var.exp_cluster ? "exp-1-" : ""}credentials-provider-merit",
      ]
    }
  }
}

resource "aws_iam_role" "role" {
  count                = var.access_method == "vault_role" ? 1 : 0
  name                 = "${local.caller_team}-${local.bucket_name_without_prefixes}-bucket-${var.write_access ? "rw" : "ro"}"
  assume_role_policy   = data.aws_iam_policy_document.vault_auth.json
  permissions_boundary = "arn:aws:iam::${local.caller_account_id}:policy/sys-${local.caller_team}-boundary"
}

resource "aws_iam_role_policy" "role" {
  count  = var.access_method == "vault_role" ? 1 : 0
  name   = "${local.caller_team}-${local.bucket_name_without_prefixes}-bucket-${var.write_access ? "rw" : "ro"}"
  role   = aws_iam_role.role[0].id
  policy = var.write_access ? data.aws_iam_policy_document.rw.json : data.aws_iam_policy_document.ro.json
}

output "role" {
  value = {
    name = length(aws_iam_role.role) > 0 ? aws_iam_role.role[0].name : ""
    arn  = length(aws_iam_role.role) > 0 ? aws_iam_role.role[0].arn : ""
  }
}
