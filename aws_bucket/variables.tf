variable "name" {
  description = "(required) Descriptive name of the bucket, without any prefixes"
}

variable "team" {
  description = "(required) Name of the team"
}

variable "environment" {
  description = "(required) AWS environment name. e.g. dev, prod"
  default     = "dev"
}

variable "public" {
  description = "Should the bucket objects be publicly accesible?"
  type        = bool
  default     = false
}

variable "object_expiration" {
  description = "Enable object deletion after a defined amount of days"
  type        = bool
  default     = false
}

variable "object_expiration_days" {
  description = "Amount of days before expiration"
  type        = number
  default     = 30
}

variable "versioning" {
  description = "Enable versioning for bucket objects"
  type        = bool
  default     = false
}

variable "version_expiration" {
  description = "Enable version deletion after a defined amount of days"
  type        = bool
  default     = false
}

variable "version_expiration_days" {
  description = "Amount of days before expiration of past versions"
  type        = number
  default     = 30
}

locals {
  # bucket name that complies with UW's permission boundaries
  prefixed_name = "uw-${var.environment}-${var.team}-${var.name}"
}
