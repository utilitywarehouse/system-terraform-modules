
locals {
  permission_set_name = "repo_${var.org}_${var.repository}"
  policy_name         = "github_${local.permission_set_name}"
}

resource "vault_generic_endpoint" "repo_permission_set" {
  path = "${var.github_secret_backend_path}/permissionset/${local.permission_set_name}"

  data_json = jsonencode({
    installation_id = var.github_app_install_id
    permissions     = var.permissions
    repositories    = var.target_repositories
  })
  write_fields         = ["installation_id", "permissions", "repositories"]
  ignore_absent_fields = true
}

# Create a token automatically constrained by the repo's permission set.
resource "vault_policy" "repo" {
  name   = local.policy_name
  policy = <<-EOT
  path "${var.github_secret_backend_path}/token/${local.permission_set_name}" {
    capabilities = ["read"]
  }
  EOT
}

resource "vault_jwt_auth_backend_role" "repo" {
  role_name = local.policy_name

  role_type = "jwt"
  backend   = var.github_auth_backend_path

  bound_audiences = ["https://github.com/${var.org}"]
  bound_claims = {
    repository_owner      = var.org,
    repository_visibility = var.repository_visibility
    repository            = "${var.org}/${var.repository}"
  }

  user_claim = "repository"

  token_ttl      = 3600 // match github token validity
  token_policies = concat(var.additional_token_policies, [vault_policy.repo.name])
}
