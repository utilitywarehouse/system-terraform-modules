/*
 * ReadOnlyAccess covers the control plane of every service, which is what
 * looking around an account needs, but it reads data too: object bodies,
 * parameter values, table items, log and message payloads, container images,
 * instance user data. The denies below are what make the role safe to hand to
 * a person or an agent that is only meant to examine infrastructure.
 *
 * ReadOnlyAccess is a deny-nobody policy and grows data actions over time, so
 * this list needs a review whenever the AWS managed policy is next revised.
 *
 * CloudWatch Logs is deliberately absent, as are metrics, traces and
 * CloudTrail: without them the role cannot answer "why is this broken".
 */

data "aws_iam_policy_document" "deny_data_reads" {
  # Object bodies, including the S3 sibling services and directory buckets. No
  # exception for the state buckets: terraform state holds credentials too.
  statement {
    sid    = "NoObjectBodies"
    effect = "Deny"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAttributes",
      "s3-object-lambda:GetObject",
      "s3-object-lambda:GetObjectVersion",
      "s3-outposts:GetObject",
      "s3-outposts:GetObjectVersion",
      "s3-outposts:GetObjectVersionForReplication",
      "s3express:CreateSession",
    ]

    resources = ["*"]
  }

  # S3 Tables and S3 Vectors data is not reached through s3:GetObject.
  statement {
    sid    = "NoS3TablesAndVectorData"
    effect = "Deny"

    actions = [
      "s3tables:GetTableData",
      "s3vectors:GetVectors",
      "s3vectors:QueryVectors",
    ]

    resources = ["*"]
  }

  # Queue and stream payloads. ReceiveMessage also hides messages from real
  # consumers for the visibility timeout.
  statement {
    sid    = "NoMessageBodies"
    effect = "Deny"

    actions = [
      "sqs:ReceiveMessage",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesisvideo:GetClip",
      "kinesisvideo:GetDASHStreamingSessionURL",
      "kinesisvideo:GetHLSStreamingSessionURL",
      "kinesisvideo:GetImages",
      "kinesisvideo:GetMedia",
      "kinesisvideo:GetMediaForFragmentList",
    ]

    resources = ["*"]
  }

  # Database logs and Performance Insights dimensions carry query text.
  statement {
    sid    = "NoDatabaseLogsOrQueryText"
    effect = "Deny"

    actions = [
      "rds:DownloadCompleteDBLogFile",
      "rds:DownloadDBLogFilePortion",
      "pi:DescribeDimensionKeys",
      "pi:GetDimensionKeyDetails",
      "pi:GetResourceMetrics",
    ]

    resources = ["*"]
  }

  # Image and function layers are source code: whatever a build baked in is
  # readable. Lambda hands out presigned S3 URLs, so the S3 deny does not help.
  statement {
    sid    = "NoContainerImagesOrFunctionCode"
    effect = "Deny"

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "lambda:GetFunction",
      "lambda:GetLayerVersion",
    ]

    resources = ["*"]
  }

  # Console output and user data: cloud-init frequently carries bootstrap
  # secrets, and DescribeInstanceAttribute is the only way to fetch user data.
  statement {
    sid    = "NoInstanceConsoleOutputOrUserData"
    effect = "Deny"

    actions = [
      "ec2:DescribeInstanceAttribute",
      "ec2:GetConsoleOutput",
      "ec2:GetConsoleScreenshot",
      "ec2:GetInstanceUefiData",
      "ec2:GetLaunchTemplateData",
      "ec2:GetPasswordData",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "NoArchiveRetrieval"
    effect    = "Deny"
    actions   = ["glacier:GetJobOutput"]
    resources = ["*"]
  }

  # Search indexes, ledgers, and knowledge bases return the documents themselves.
  statement {
    sid    = "NoSearchOrKnowledgeBaseContent"
    effect = "Deny"

    actions = [
      "es:ESHttpGet",
      "es:ESHttpHead",
      "cassandra:Select",
      "kendra:Query",
      "qldb:GetBlock",
      "qldb:GetRevision",
      "bedrock:AgenticRetrieveStream",
      "bedrock:GetAgentMemory",
      "bedrock:GetDocumentContent",
      "bedrock:GetExecutionFlowSnapshot",
      "bedrock:GetFlowExecution",
      "bedrock:GetInvocationStep",
      "bedrock:GetInvoke",
      "bedrock:GetKnowledgeBaseDocuments",
      "bedrock:GetSession",
      "bedrock:Retrieve",
      "bedrock-mantle:GetFile",
      "bedrock-mantle:GetInference",
    ]

    resources = ["*"]
  }

  # AgentCore memory, session and payment records.
  statement {
    sid    = "NoAgentCoreSessionData"
    effect = "Deny"

    actions = [
      "bedrock-agentcore:GetBrowserSession",
      "bedrock-agentcore:GetCodeInterpreterSession",
      "bedrock-agentcore:GetEvent",
      "bedrock-agentcore:GetMemory",
      "bedrock-agentcore:GetMemoryRecord",
      "bedrock-agentcore:GetPaymentInstrument",
      "bedrock-agentcore:GetPaymentInstrumentBalance",
      "bedrock-agentcore:GetPaymentSession",
      "bedrock-agentcore:ListEvents",
      "bedrock-agentcore:RetrieveMemoryRecords",
    ]

    resources = ["*"]
  }

  # Parameter and command values: the API cannot say which parameter is a
  # secret before reading it, and RunCommand output can contain anything.
  statement {
    sid    = "NoSsmValuesOrCommandOutput"
    effect = "Deny"

    actions = [
      "ssm:GetAutomationExecution",
      "ssm:GetCommandInvocation",
      "ssm:GetInventory",
      "ssm:GetOpsSummary",
      "ssm:GetParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = ["*"]
  }

  # ReadOnlyAccess does not carry secretsmanager:GetSecretValue today. The
  # deny keeps a future revision of that policy from handing out secrets.
  statement {
    sid    = "NoSecretValues"
    effect = "Deny"

    actions = [
      "secretsmanager:BatchGetSecretValue",
      "secretsmanager:GetSecretValue",
    ]

    resources = ["*"]
  }

  # Item APIs, plus streams, vector search and replication, which carry the
  # same item data under different action names.
  statement {
    sid    = "NoDynamodbItemReads"
    effect = "Deny"

    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:PartiQLSelect",
      "dynamodb:Query",
      "dynamodb:ReadDataForReplication",
      "dynamodb:Scan",
      "dynamodb:SearchVectors",
    ]

    resources = ["*"]
  }

  # Results of queries somebody else ran; starting executions is not granted.
  statement {
    sid    = "NoAthenaQueryResults"
    effect = "Deny"

    actions = [
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
    ]

    resources = ["*"]
  }

  # Stack templates can carry inline credentials.
  statement {
    sid       = "NoStackTemplates"
    effect    = "Deny"
    actions   = ["cloudformation:GetTemplate"]
    resources = ["*"]
  }
}
