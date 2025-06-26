# RDS backup plan role Terraform module

This module sets up the AWS IAM role to be used in the [backup plan](https://docs.aws.amazon.com/aws-backup/latest/devguide/about-backup-plans.html) for an RDS instance.

## Usage

```terraform
# declare the role
module "rds_backup_plan_role" {
  source   = "github.com/utilitywarehouse/system-terraform-modules//rds_backup_plan_role?ref=d044000e7f1164abb48d984035e8dc8b43e13434"
  account_id = var.account_id
  team       = local.team
  rds_name   = local.rds_name
}

# use the role in a backup plan selection
resource "aws_backup_selection" "rds_backup_selection" {
  name         = "${local.rds_name}-backup-selection"
  plan_id      = aws_backup_plan.rds_backup_plan.id
  iam_role_arn = module.rds_backup_plan_role.role.arn

  resources = [
    aws_db_instance.postgres.arn
  ]
}
```
