data "aws_iam_policy_document" "auth" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = var.jump_role_arns
    }

    condition {
      test     = "ForAnyValue:StringEqualsIgnoreCase"
      variable = "aws:PrincipalTag/login"
      values   = var.logins
    }
  }
}

resource "aws_iam_role" "role" {
  name        = var.role_name
  description = "Read-only access to every service, without object bodies, parameter values or secret values"

  assume_role_policy = data.aws_iam_policy_document.auth.json
}

resource "aws_iam_role_policy_attachment" "read_only_access" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "deny_data_reads" {
  name   = "deny-data-reads"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.deny_data_reads.json
}
