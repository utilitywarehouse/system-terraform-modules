data "aws_caller_identity" "current" {}

locals {
  caller_account_id    = data.aws_caller_identity.current.account_id
  caller_team          = trimsuffix(split("/", data.aws_caller_identity.current.arn)[1], "-admin")
}
