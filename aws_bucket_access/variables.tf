variable "bucket_id" {
  description = "Id of the bucket to be accessed"

  validation {
    condition     = substr(var.bucket_id, 0, 3) == "uw-"
    error_message = "The bucket_id must follow the format 'uw-<environment>-<team>-*'."
  }
}

variable "access_method" {
  type        = string
  description = "Type of bucket access. Can be 'iam_role' or 'iam_user'."
  default     = "iam_role"

  validation {
    condition     = contains(["iam_role", "iam_user"], var.access_method)
    error_message = "The access_type must be one of: iam_role, iam_user."
  }
}

variable "write_access" {
  description = "Should have write access?"
  type        = bool
  default     = false
}

variable "iam_role_auth_policy" {
  description = "Auth policy for the iam_role. If left blank, only vault would be able to assume the role"
  type        = string
  default     = ""
}

locals {
  bucket_name_without_uw       = trimprefix(var.bucket_id, "uw-")
  bucket_name_without_env      = trimprefix(local.bucket_name_without_uw, local.caller_account_alias)
  bucket_name_without_prefixes = trimprefix(local.bucket_name_without_env, "-${local.caller_team}-")
}
