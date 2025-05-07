data "aws_caller_identity" "current" {}

locals {
  uw_account_aliases_map = {
    950135041896 = "dev"
    703452047160 = "prod"
  }
  caller_account_id    = data.aws_caller_identity.current.account_id
  caller_team          = trimsuffix(split("/", data.aws_caller_identity.current.arn)[1], "-admin")
}
