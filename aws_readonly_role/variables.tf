variable "role_name" {
  description = "Name of the read-only role"
  type        = string
  default     = "system-readonly"
}

variable "jump_role_arns" {
  description = "(required) ARNs of the SSO jump roles whose sessions may assume this role"
  type        = list(string)
}

variable "logins" {
  description = "(required) Logins allowed to assume this role, matched against the aws:PrincipalTag/login tag the jump role sets on the session"
  type        = list(string)
}
