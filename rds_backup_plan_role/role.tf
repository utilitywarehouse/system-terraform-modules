data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup_role" {
  name                 = "${var.rds_name}-backup-role"
  permissions_boundary = "arn:aws:iam::${local.caller_account_id}:policy/sys-${var.team}-boundary"
  assume_role_policy   = data.aws_iam_policy_document.backup_assume_role.json
}

data "aws_iam_policy_document" "backup_policy" {
  # build from https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSBackupServiceRolePolicyForBackup.html
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:DescribeDBSnapshots",
      "rds:ListTagsForResource",
      "rds:ModifyDBInstance",
      "rds:DeleteDBInstanceAutomatedBackup",
      "rds:ModifyDBCluster",
      "rds:DeleteDBClusterAutomatedBackup"
    ]
    resources = [
      "arn:aws:rds:*:*:*:${var.team}-*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "rds:CreateDBSnapshot",
      "rds:AddTagsToResource"
    ]
    resources = [
      "arn:aws:rds:*:*:snapshot:awsbackup:*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/owner"
      values = [
        var.team
      ]
    }

  }

  # needs describes on all to create snapshots
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBSnapshots",
    ]
    resources = [
      "arn:aws:rds:*:*:snapshot:awsbackup:*",
    ]
  }

  statement {
    # full team backup access
    actions = [
      "backup:StartBackupJob",
      "backup:StopBackupJob",
      "backup:ListBackupJobs",
      "backup:ListBackupPlans",
      "backup:ListBackupVaults",
      "backup:GetBackupPlan",
      "backup:GetBackupVaultAccessPolicy",
      "backup:GetBackupVaultNotifications",
      "backup:PutBackupVaultAccessPolicy",
      "backup:PutBackupVaultNotifications",
      "backup:DescribeBackupVault",
      "backup:CopyIntoBackupVault",
      "backup:CopyFromBackupVault"
    ]

    resources = [
      "arn:aws:backup:*:*:*:${var.team}-*",
    ]
  }

  statement {
    sid    = "KmsPermissions"
    effect = "Allow"
    actions = [
      "kms:List*",
      "kms:Describe*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMSCreateGrantPermissions"
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid       = "GetResourcesPermissions"
    effect    = "Allow"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "backup_policy_attachment" {
  name   = "${var.rds_name}-backup-role-policy"
  role   = aws_iam_role.backup_role.name
  policy = data.aws_iam_policy_document.backup_policy.json
}

output "role" {
  value = {
    name = aws_iam_role.backup_role.name
    arn  = aws_iam_role.backup_role.arn
  }
}
