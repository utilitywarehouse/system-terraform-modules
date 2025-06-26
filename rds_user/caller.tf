# Based on https://github.com/utilitywarehouse/system-terraform-modules/blob/main/aws_bucket_access/caller.tf
data "aws_caller_identity" "current" {}

locals {
  caller_account_id = data.aws_caller_identity.current.account_id
}
