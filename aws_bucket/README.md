# Bucket module
This module creates an s3 bucket following UW's guidelines, which include:
* automatic prefix to comply with team's permissions boundary
* private by default, compliant with security audits' requirements
* encryption at rest
* tags for cost allocation
* support for versioning and expiration

If importing an existing bucket with a legacy name, the variable
`name_is_legacy` can be set to keep the defined name without applying automatic
prefixes.

# Usage
## Private bucket
```
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  name   = "app-data"
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Private bucket with a legacy name
```
module "mybucket" {
  source         = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  name           = "existing-bucket-name-with-an-exception-in-the-team-boundary"
  name_is_legacy = true
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Publicly accesible bucket
```
module "mybucket" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  name   = "app-data"
  public = true
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Bucket with object expiration
```
module "mybucket" {
  source                 = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  name                   = "app-data"
  object_expiration      = true
  object_expiration_days = 90 # default: 30 days
}

output "mybucket" {
  value = module.mybucket.bucket
}
```

## Bucket with versioning enabled and expiration for the versions
```
module "mybucket" {
  source                  = "github.com/utilitywarehouse/system-terraform-modules//aws_bucket?ref=X.X.X"
  name                    = "app-data"
  versioning              = true
  version_expiration      = true
  version_expiration_days = 60 # default: 30 days
}

output "mybucket" {
  value = module.mybucket.bucket
}
```
