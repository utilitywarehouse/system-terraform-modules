variable "team" {
  description = "(required) Name of the team"
}

variable "name" {
  description = "Name of the user"
}

variable "database" {
  description = "Database the user gets access to"
}

variable "existing_iam_role" {
  type        = string
  description = "The IAM role name to grant privileges to. This allows using an already existing role that is used with vault, and it will add to its privileges. For example enables an app to connect both to S3 and to RDS using a single role"
  nullable    = true
  default     = null
}

variable "privilege" {
  description = "Type of privilege to grant user on the specified database"
  validation {
    condition     = contains(["read", "read/write", "none"], var.privilege)
    error_message = "Privilege must be one of 'read','read/write' or 'none'"
  }
  default = "read"
}

variable "db_instance" {
  description = "The aws_db_instance for which the user is defined"
  type = object({
    id         = string
    arn        = string
    identifier = string
  })
}
