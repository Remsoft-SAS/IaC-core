# modules/lambda/main.tf
# Smart Lambda Module: Automates permissions and event mappings based on ARN detection

locals {
  full_function_name = "${var.function_name}-${var.environment}"
  
  # --- Smart Detection Logic ---
  arn = var.event_source_arn != null ? var.event_source_arn : ""
  
  # Pull Models (Requires Event Source Mapping)
  is_sqs      = length(regexall(":sqs:", local.arn)) > 0
  is_dynamodb = length(regexall(":dynamodb:", local.arn)) > 0
  
  # Push Models (Requires Lambda Permission)
  is_apigateway = length(regexall("execute-api|:apigateway:", local.arn)) > 0
  is_sns        = length(regexall(":sns:", local.arn)) > 0
  is_s3         = length(regexall("^arn:aws:s3:::", local.arn)) > 0
}

# ── IAM Execution Role ──────────────────────────────────────────────────────

resource "aws_iam_role" "this" {
  name = "${local.full_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = merge({ Name = "${local.full_function_name}-role" }, var.tags)
}

# Basic Logging
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ── Smart IAM Permissions ───────────────────────────────────────────────────

# 1. SQS Permissions
resource "aws_iam_role_policy" "sqs_consumer" {
  count = local.is_sqs ? 1 : 0
  name  = "SQSConsumerPolicy"
  role  = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Effect   = "Allow"
      Resource = [var.event_source_arn]
    }]
  })
}

# 2. DynamoDB Streams Permissions
resource "aws_iam_role_policy" "dynamodb_consumer" {
  count = local.is_dynamodb ? 1 : 0
  name  = "DynamoDBConsumerPolicy"
  role  = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:DescribeStream", "dynamodb:ListStreams"]
      Effect   = "Allow"
      Resource = [var.event_source_arn]
    }]
  })
}

# 3. VPC Support
resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# 4. Custom Inline Policies
resource "aws_iam_role_policy" "inline" {
  for_each = { for policy in var.inline_policies : policy.name => policy.policy }
  name     = each.key
  role     = aws_iam_role.this.id
  policy   = each.value
}

# ── Lambda Function ───────────────────────────────────────────────────────────

data "archive_file" "dummy" {
  count       = var.filename == null && var.s3_bucket == null ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/dummy.zip"
  source {
    content  = "exports.handler = async () => ({ statusCode: 200, body: 'Hello World' });"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "this" {
  function_name = local.full_function_name
  role          = aws_iam_role.this.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  filename          = var.filename != null ? var.filename : (var.s3_bucket == null ? data.archive_file.dummy[0].output_path : null)
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  tags = merge({ Name = local.full_function_name }, var.tags)

  lifecycle {
    ignore_changes = [filename, s3_key, s3_object_version, last_modified, source_code_hash, environment]
  }
}

# ── Smart Event Wiring ────────────────────────────────────────────────────────

# 1. Mapping (For Pull-based: SQS, DynamoDB)
resource "aws_lambda_event_source_mapping" "this" {
  count            = (local.is_sqs || local.is_dynamodb) ? 1 : 0
  event_source_arn = var.event_source_arn
  function_name    = aws_lambda_function.this.function_name
  batch_size       = var.event_source_batch_size
}

# 2. Permission (For Push-based: API GW, SNS, S3)
resource "aws_lambda_permission" "this" {
  count         = (local.is_apigateway || local.is_sns || local.is_s3) ? 1 : 0
  statement_id  = "AllowExecutionFromEventSource"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = local.is_apigateway ? "apigateway.amazonaws.com" : (local.is_sns ? "sns.amazonaws.com" : "s3.amazonaws.com")
  source_arn    = var.event_source_arn
}

# ── Logging ───────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.full_function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# ── Environment Variables Merge (CI/CD) ───────────────────────────────────────

resource "null_resource" "env_vars_merge" {
  count = length(var.environment_variables) > 0 ? 1 : 0
  triggers = {
    tf_vars       = jsonencode(var.environment_variables)
    function_name = local.full_function_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      CURRENT=$(aws lambda get-function-configuration --function-name ${aws_lambda_function.this.function_name} --query 'Environment.Variables' --output json 2>/dev/null || echo '{}')
      MERGED=$(echo "$CURRENT" | jq -c '. + ${jsonencode(var.environment_variables)}')
      aws lambda update-function-configuration --function-name ${aws_lambda_function.this.function_name} --environment "{\"Variables\":$MERGED}" --no-cli-pager > /dev/null
    EOT
  }
  depends_on = [aws_lambda_function.this]
}
