data "aws_caller_identity" "current" {}

locals {
  caller_account_id = data.aws_caller_identity.current.account_id
}
