# modules/step_functions/main.tf

locals {
  full_name = "${var.name}-${var.environment}"
}

# ── CloudWatch Log Group ───────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/states/${local.full_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# ── IAM Role ──────────────────────────────────────────────────────────────────

resource "aws_iam_role" "this" {
  name = "${local.full_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge({ Name = "${local.full_name}-role" }, var.tags)
}

# Permite invocar las Lambdas declaradas en lambda_arns
resource "aws_iam_role_policy" "invoke_lambdas" {
  count = length(var.lambda_arns) > 0 ? 1 : 0
  name  = "InvokeLambdas"
  role  = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = var.lambda_arns
    }]
  })
}

# Permite escribir logs a CloudWatch
resource "aws_iam_role_policy" "logs" {
  name = "CloudWatchLogs"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups",
      ]
      Resource = "*"
    }]
  })
}

# ── State Machine ──────────────────────────────────────────────────────────────

resource "aws_sfn_state_machine" "this" {
  name     = local.full_name
  role_arn = aws_iam_role.this.arn
  type     = var.type

  definition = var.definition

  logging_configuration {
    level                  = var.log_level
    include_execution_data = var.log_include_execution_data
    log_destination        = "${aws_cloudwatch_log_group.this.arn}:*"
  }

  tags = merge({ Name = local.full_name }, var.tags)
}

# ── EventBridge Trigger (opcional) ────────────────────────────────────────────

resource "aws_cloudwatch_event_rule" "trigger" {
  count         = var.eventbridge_trigger != null ? 1 : 0
  name          = "${local.full_name}-trigger"
  event_bus_name = var.eventbridge_trigger.bus_name
  event_pattern  = var.eventbridge_trigger.event_pattern
  tags           = var.tags
}

resource "aws_iam_role" "eventbridge" {
  count = var.eventbridge_trigger != null ? 1 : 0
  name  = "${local.full_name}-eb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "eventbridge_start" {
  count = var.eventbridge_trigger != null ? 1 : 0
  name  = "StartExecution"
  role  = aws_iam_role.eventbridge[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["states:StartExecution"]
      Resource = aws_sfn_state_machine.this.arn
    }]
  })
}

resource "aws_cloudwatch_event_target" "trigger" {
  count          = var.eventbridge_trigger != null ? 1 : 0
  rule           = aws_cloudwatch_event_rule.trigger[0].name
  event_bus_name = var.eventbridge_trigger.bus_name
  target_id      = "${local.full_name}-sfn"
  arn            = aws_sfn_state_machine.this.arn
  role_arn       = aws_iam_role.eventbridge[0].arn
}
