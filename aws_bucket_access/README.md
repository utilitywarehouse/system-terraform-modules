# Bucket access module

This modules creates means to access UW buckets

There are two access methods:

- iam role: the recommended method. It's preconfigured to be used in kubernetes with our credential-less [vault setup](https://github.com/utilitywarehouse/documentation/blob/master/infra/vault-aws.md#vault-aws-credentials), but can be used anywhere by providing a custom auth policy with the `iam_role_auth_policy` variable
- iam user: alternative method, with long term credentials usable from anywhere

Write access is optional, disabled by default

## Requirements

This module expects bucket_id with format `uw-<environment>-<team>-my-bucket`

# Usage

## Role with read only access

```terraform
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team   = "finance"
  name   = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}

module "access_role" {
  source    = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket_access?ref=X.X.X"
  team      = "finance"
  bucket_id = module.mybucket.bucket.id
}

output "role" {
  value = module.access_role.role
}
```

## Role with read and write access

```terraform
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team   = "finance"
  name   = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}

module "access_role" {
  source       = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket_access?ref=X.X.X"
  team         = "finance"
  bucket_id    = module.mybucket.bucket.id
  write_access = true
}

output "role" {
  value = module.access_role.role
}
```

## Role with custom assume policy, to be used outside of our vault-setup (example for the aws transfer (sftp) server)

```terraform
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team   = "finance"
  name   = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}

data "aws_iam_policy_document" "aws_transfer_auth" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

module "access_role" {
  source    = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket_access?ref=X.X.X"
  team      = "finance"
  bucket_id = module.mybucket.bucket.id

  iam_role_auth_policy = data.aws_iam_policy_document.aws_transfer_auth.json
}

output "role" {
  value = module.access_role.role
}
```

## User with read only access

```terraform
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team   = "finance"
  name   = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}

module "access_user" {
  source        = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket_access?ref=X.X.X"
  team          = "finance"
  bucket_id     = module.mybucket.bucket.id
  access_method = "iam_user"
}

output "user" {
  value = module.access_user.user
}

output "access_key" {
  value     = module.access_user.access_key
  sensitive = true
}
```

## User with read and write access

```terraform
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team   = "finance"
  name   = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}

module "access_user" {
  source        = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket_access?ref=X.X.X"
  team          = "finance"
  bucket_id     = module.mybucket.bucket.id
  access_method = "iam_user"
  write_access  = true
}

output "user" {
  value = module.access_user.user
}

output "access_key" {
  value     = module.access_user.access_key
  sensitive = true
}
```
