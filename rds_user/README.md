# RDS user Terraform module

This module sets up the AWS IAM & AWS RDS instance to allow a user to connect to an RDS postgres DB.

See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html.

Consult [iam.tf](iam.tf) and [postgres.tf](postgres.tf) to see what resources it defines and [variables.tf](variables.tf) for available input variables.

## Usage example:

```terraform
# Example for user with read and write permissions
module "rw-user" {
  source      = "github.com/utilitywarehouse/system-terraform-modules//rds_user?ref=f59eaabd6aefe0e27b9a7fa8d254eef7e05bf202"
  name        = "rw-user"
  database    = postgresql_database.my_db.name
  privilege   = "read/write"
  db_instance = aws_db_instance.postgres
}

# Example for user with read-only permissions
module "ro-user" {
  source      = "github.com/utilitywarehouse/system-terraform-modules//rds_user?ref=f59eaabd6aefe0e27b9a7fa8d254eef7e05bf202"
  name        = "ro-user"
  database    = postgresql_database.my_db.name
  privilege   = "read"
  db_instance = aws_db_instance.postgres
}

# Example for using an already existing IAM role used for accessing an S3 bucket: 
module "sample_db_existing_role" {
  source      = "github.com/utilitywarehouse/system-terraform-modules//rds_user?ref=b07882f5fd16608af060ba589bf9f4db578a411a"
  name        = "sample-db-existing-role"
  database    = postgresql_database.sample_db.name
  privilege   = "read/write"
  db_instance = aws_db_instance.postgres
  existing_iam_role = "dev-enablement-test-backups-bucket-rw"
}

```
