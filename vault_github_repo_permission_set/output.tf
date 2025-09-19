output "role_name" {
  value = vault_jwt_auth_backend_role.repo.role_name
}

output "secret_path" {
  value = "/${var.github_secret_backend_path}/token/${local.permission_set_name}"
}
