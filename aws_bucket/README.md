# Bucket module

This module creates an s3 bucket following UW's guidelines, which include:

- automatic prefix to comply with team's permissions boundary
- private by default, compliant with security audits' requirements
- encryption at rest
- tags for cost allocation
- support for versioning and expiration
- uses [Intelligent Tiering](https://aws.amazon.com/s3/storage-classes/intelligent-tiering/) by default 

# Usage

## Private bucket

```terraform
module "mybucket" {
  source      = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team        = "finance"
  name        = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Publicly accesible bucket

```terraform
module "mybucket" {
  source      = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team        = "finance"
  name        = "app-data"
  public      = true
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Bucket with object expiration

```terraform
module "mybucket" {
  source                 = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team                   = "finance"
  name                   = "app-data"
  object_expiration      = true
  object_expiration_days = 90 # default: 30 days
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Bucket without intelligent tiering

```terraform
module "mybucket" {
  source                  = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team                    = "finance"
  name                    = "app-data"
  use_intelligent_tiering = false
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Bucket with versioning enabled and expiration for the versions

```terraform
module "mybucket" {
  source                  = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  team                    = "finance"
  name                    = "app-data"
  versioning              = true
  version_expiration      = true
  version_expiration_days = 60 # default: 30 days
}

output "mybucket" {
  value = module.mybucket.bucket
}
```
