variable "github_auth_backend_path" {
  default = "github-jwt"
}
variable "github_secret_backend_path" {
  default = "github"
}

variable "github_app_install_id" { type = number }

variable "org" { type = string }

variable "repository" { type = string }

variable "repository_visibility" {
  type    = string
  default = "private"
}

variable "target_repositories" {
  type     = list(string)
  nullable = true

  validation {
    condition     = length(var.target_repositories) > 0
    error_message = "'target_repositories' is required"
  }
}

variable "permissions" {
  type     = map(string)
  nullable = true

  validation {
    condition     = length(var.permissions) > 0
    error_message = "'permissions' is required"
  }
}

variable "additional_token_policies" {
  type     = list(string)
  default  = null
  nullable = true
}
