variable "name" {
  description = "Descriptive name of the bucket, without any prefixes"
}

variable "public" {
  description = "Should the bucket objects be publicly accesible?"
  type        = bool
  default     = false
}

locals {
  # bucket name that complies with UW's permission boundaries
  prefixed_name = "uw-${local.caller_account_alias}-${local.caller_team}-${var.name}"
}
