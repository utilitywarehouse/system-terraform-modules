resource "aws_iam_user" "user" {
  count                = var.access_method == "iam_user" ? 1 : 0
  name                 = "${local.caller_team}-${local.bucket_name_without_prefixes}-bucket-${var.write_access ? "rw" : "ro"}"
  permissions_boundary = "arn:aws:iam::${local.caller_account_id}:policy/sys-${local.caller_team}-boundary"
}

resource "aws_iam_user_policy" "user" {
  count  = var.access_method == "iam_user" ? 1 : 0
  name   = "${local.caller_team}-${local.bucket_name_without_prefixes}-bucket-${var.write_access ? "rw" : "ro"}"
  user   = aws_iam_user.user[0].name
  policy = var.write_access ? data.aws_iam_policy_document.rw.json : data.aws_iam_policy_document.ro.json
}

resource "aws_iam_access_key" "user" {
  count = var.access_method == "iam_user" ? 1 : 0
  user  = aws_iam_user.user[0].name
}

output "user" {
  value = {
    name = length(aws_iam_user.user) > 0 ? aws_iam_user.user[0].name : ""
    arn  = length(aws_iam_user.user) > 0 ? aws_iam_user.user[0].arn : ""
  }
}

output "access_key" {
  value = {
    id     = length(aws_iam_access_key.user) > 0 ? aws_iam_access_key.user[0].id : ""
    secret = length(aws_iam_access_key.user) > 0 ? aws_iam_access_key.user[0].secret : ""
  }
  sensitive = true
}
