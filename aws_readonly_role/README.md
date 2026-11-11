# Read-only role module

This module creates the role a person or an agent assumes to look around an AWS
account without being able to change anything in it.

It attaches the AWS managed `ReadOnlyAccess` policy, which covers the control
plane of every service but reads data as well: object bodies from every bucket
(terraform state included), parameter and secret values, DynamoDB items, queue and
stream payloads, container images, instance user data, and knowledge-base
content. An inline policy denies those reads, so the role answers "what is
deployed and how is it configured" without returning stored secrets or object,
row and message data.

CloudWatch Logs, metrics, traces and CloudTrail are left readable: without them
the role cannot answer "why is this broken". Log bodies are not filtered, so
anything written to a log stays readable through this role. `ReadOnlyAccess` is
a deny-nobody policy and gains data actions over time, so review the inline
policy when the AWS managed policy is next revised.

No permissions boundary is attached, because the `sys-<team>-boundary` in each
account allows only a small part of what `ReadOnlyAccess` allows, and the
intersection would leave the role unable to do anything useful.

## Requirements

The role is assumed through the SSO jump role, so the caller passes the ARNs of
the jump roles that may assume it and the logins that may do so. The login is
matched against the `aws:PrincipalTag/login` tag the jump role sets on the
session.

# Usage

```terraform
module "system_readonly" {
  source = "github.com/utilitywarehouse/system-terraform-modules//aws_readonly_role?ref=X.X.X"

  jump_role_arns = ["arn:aws:iam::703452047160:role/sys-sso-jump-role"]

  logins = [
    "person@uw.co.uk",
  ]
}
```
