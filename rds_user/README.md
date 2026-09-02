# RDS user Terraform module

This module sets up the AWS IAM & AWS RDS instance to allow a user to connect to an RDS postgres DB.

See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html.

Consult [iam.tf](iam.tf) and [postgres.tf](postgres.tf) to see what resources it defines and [variables.tf](variables.tf) for available input variables.

## Known issues

### Apply fails with AccessDenied

**Example failure**:
```
Error: putting IAM Role (leads-platform-rds-lead_sharing) Policy (leads-platform-rds-lead_sharing): operation error IAM: PutRolePolicy, https response error StatusCode: 403, RequestID: xxxxxxxxxxxxxxxxxx, api error AccessDenied: User: arn:aws:sts::xxxxxxxxx:assumed-role/leads-platform-admin/aws-go-sdk-xxxxxxxxxxx is not authorized to perform: iam:PutRolePolicy on resource: role leads-platform-rds-lead_sharing because no permissions boundary allows the iam:PutRolePolicy action
```

**Reason**: [the role and its role policy](https://github.com/utilitywarehouse/system-terraform-modules/blob/4b8963f1d30253e65ddd6f39927d7b75988886d7/rds_user/iam.tf#L24-L36) creation was launched in parallel, as there was no implicit or explicit dependency between them. And so the role policy often didn't find the role to be attached to.

**Fix**: use at least revision [64078164e7578614c4d5506ac9601a8cf81dbf58](https://github.com/utilitywarehouse/system-terraform-modules/commit/64078164e7578614c4d5506ac9601a8cf81dbf58) of the module where an implicit dependency was implemented.

**Workaround**: retry the apply. The role will be eventually created and the policy will find it.
## Usage example:

```terraform
# Example for user with read and write permissions
module "rw-user" {
  source      = "git@github.com:utilitywarehouse/system-terraform-modules//rds_user?ref=64078164e7578614c4d5506ac9601a8cf81dbf58"
  team        = "finance"
  name        = "rw-user"
  database    = postgresql_database.my_db.name
  privilege   = "read/write"
  db_instance = aws_db_instance.postgres
}

# Example for user with read-only permissions
module "ro-user" {
  source      = "git@github.com:utilitywarehouse/system-terraform-modules//rds_user?ref=64078164e7578614c4d5506ac9601a8cf81dbf58"
  team        = "finance"
  name        = "ro-user"
  database    = postgresql_database.my_db.name
  privilege   = "read"
  db_instance = aws_db_instance.postgres
}

# Example for user with no permissions and then defining custom grants
module "custom-grants-user" {
  source      = "git@github.com:utilitywarehouse/system-terraform-modules//rds_user?ref=64078164e7578614c4d5506ac9601a8cf81dbf58"
  team        = "finance"
  name        = "custom-grants"
  database    = postgresql_database.my_db.name
  privilege   = "none"
  db_instance = aws_db_instance.postgres
}

resource "postgresql_grant" "db_grant" {
  database    = postgresql_database.my_db.name
  role        = "custom-grants"
  object_type = "database"
  privileges  = ["CONNECT", "CREATE"]
  depends_on  = [module.custom-grants-user.postgresql_role]
}


# Example for using an already existing IAM role used for accessing an S3 bucket:
module "sample_db_existing_role" {
  source      = "git@github.com:utilitywarehouse/system-terraform-modules//rds_user?ref=64078164e7578614c4d5506ac9601a8cf81dbf58"
  team        = "finance"
  name        = "sample-db-existing-role"
  database    = postgresql_database.sample_db.name
  privilege   = "read/write"
  db_instance = aws_db_instance.postgres
  existing_iam_role = "dev-enablement-test-backups-bucket-rw"
}

# Example for granting the user additional postgres roles (e.g. rds_superuser)
module "sample_db_extra_roles" {
  source         = "git@github.com:utilitywarehouse/system-terraform-modules//rds_user?ref=64078164e7578614c4d5506ac9601a8cf81dbf58"
  team           = "finance"
  name           = "sample-db-extra-roles"
  database       = postgresql_database.sample_db.name
  privilege      = "read/write"
  db_instance    = aws_db_instance.postgres
  extra_pg_roles = ["pg_monitor"]
}
```
