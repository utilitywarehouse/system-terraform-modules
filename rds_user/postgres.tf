terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.24.0"
    }
  }
}

# Creates the role in postgres with the appropriate privileges.
resource "postgresql_role" "pg_access_role" {
  name     = var.name
  login    = true
  password = "NULL"
  # Allows access for this role through IAM authentication.
  # See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.DBAccounts.html
  roles = ["rds_iam"]
}

resource "postgresql_grant" "db_grant" {
  database    = var.database
  role        = var.name
  object_type = "database"
  privileges  = var.privilege == "read" ? ["CONNECT"] : ["CONNECT", "CREATE", "TEMPORARY"]
  depends_on  = [postgresql_role.pg_access_role]
}

resource "postgresql_grant" "schema_grant" {
  database    = var.database
  role        = var.name
  object_type = "schema"
  schema      = "public"
  privileges  = var.privilege == "read" ? ["USAGE"] : ["CREATE", "USAGE"]
  depends_on  = [postgresql_role.pg_access_role]
}

resource "postgresql_grant" "table_grant" {
  database    = var.database
  role        = var.name
  object_type = "table"
  schema      = "public"
  privileges  = var.privilege == "read" ? ["SELECT"] : ["DELETE", "INSERT", "REFERENCES", "SELECT", "TRIGGER", "TRUNCATE", "UPDATE"]
  depends_on  = [postgresql_role.pg_access_role]
}
