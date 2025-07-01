data "aws_caller_identity" "current" {}

locals {
  uw_account_aliases_map = {
    950135041896 = "dev"
    703452047160 = "prod"
    229806150680 = "explore"
  }
  caller_account_id    = data.aws_caller_identity.current.account_id
  caller_account_alias = local.uw_account_aliases_map[local.caller_account_id]
}
