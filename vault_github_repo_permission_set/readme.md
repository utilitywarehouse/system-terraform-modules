# Usage

These terraform modules configure Vault. It creates required `permissionset`,
`policy` and `jwt` role to get github access token when [vault-plugin-secrets-github](https://github.com/martinbaillie/vault-plugin-secrets-github)
is used. 

With following config github repo `my_org/my_repo` will be able to request a Github Token via vault. 
Token will have `write` access to `contents and pull_requests` in `my_repo and other-repo`

```hcl
module "my_repo" {
  source                = "git@github.com:utilitywarehouse/system-terraform-modules//vault_github_repo_permission_set?ref=main"
  
  # The ID of the Github app installation in the org
  github_app_install_id = var.github_app_install_id

  # The name of org and repository from which workflows will be requesting this
  # access token
  org        = "my_org"
  repository = "my_repo"

  # A list of the names of the repositories within the organisation that the 
  # access token should have access to.
  target_repositories = [
    "my_repo",
    "other-repo",
  ]

  # A key value map of permission names to their access type (read or write). 
  # See GitHub’s documentation on permission names and access types.
  # https://developer.github.com/v3/apps/permissions
  #	https://docs.github.com/en/rest/apps/apps#create-an-installation-access-token-for-an-app
  permissions = {
    contents      = "write"
    metadata      = "read"
    pull_requests = "write"
  }

  # This module creates role and adds a policy for above permissions but if additional
  # policy access is required then it can be added here 
  additional_token_policies = [
    vault_policy.shared_repos_ro.name
  ]
}

output "my_repo_role_name" {
  value = module.my_repo.role_name
}
output "my_repo_secret_path" {
  value = module.my_repo.secret_path
}
```

`terraform plan` produces this output

```hcl
 # module.my_repo.vault_generic_endpoint.repo_permission_set will be created
  + resource "vault_generic_endpoint" "repo_permission_set" {
      + data_json            = (sensitive value)
      + disable_delete       = false
      + disable_read         = false
      + id                   = (known after apply)
      + ignore_absent_fields = true
      + path                 = "github/permissionset/repo_my_org_my_repo"
      + write_data           = (known after apply)
      + write_data_json      = (known after apply)
      + write_fields         = [
          + "installation_id",
          + "permissions",
          + "repositories",
        ]
    }

  # module.my_repo.vault_jwt_auth_backend_role.repo will be created
  + resource "vault_jwt_auth_backend_role" "repo" {
      + backend                      = "github-jwt"
      + bound_audiences              = [
          + "https://github.com/my_org",
        ]
      + bound_claims                 = {
          + "repository"            = "my_org/my_repo"
          + "repository_owner"      = "my_org"
          + "repository_visibility" = "private"
        }
      + bound_claims_type            = (known after apply)
      + clock_skew_leeway            = 0
      + disable_bound_claims_parsing = false
      + expiration_leeway            = 0
      + id                           = (known after apply)
      + not_before_leeway            = 0
      + role_name                    = "github_repo_my_org_my_repo"
      + role_type                    = "jwt"
      + token_policies               = [
          + "github_repo_my_org_my_repo",
          + "github_shared_repos_ro",
        ]
      + token_ttl                    = 3600
      + token_type                   = "default"
      + user_claim                   = "repository"
      + user_claim_json_pointer      = false
      + verbose_oidc_logging         = false
    }

  # module.my_repo.vault_policy.repo will be created
  + resource "vault_policy" "repo" {
      + id     = (known after apply)
      + name   = "github_repo_my_org_my_repo"
      + policy = <<-EOT
            path "github/token/repo_my_org_my_repo" {
              capabilities = ["read"]
            }
        EOT
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + my_repo_role_name           = "github_repo_my_org_my_repo"
  + my_repo_secret_path         = "/github/token/repo_my_org_my_repo"

```

## Requesting the access token via `hashicorp/vault-action`

Example of vault-action config to generate Github Tokens based on permission set
configured via this module 

```yaml
jobs:
  fetch-github-tokens:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Fetch Github Tokens
        id: fetch-github-tokens
        uses: hashicorp/vault-action@v2
        with:
          url: VAULT-URL
          method: jwt
          path: github-jwt
          exportEnv: false
          role: github_repo_${{ github.repository_owner }}_${{ github.event.repository.name }}
          secrets: |
            /github/token/shared_repos_ro token | GITHUB_REPOS_RO_TOKEN ;
            /github/token/repo_${{ github.repository_owner }}_${{ github.event.repository.name }} token | GITHUB_DEPLOY_TOKEN ;
      
```