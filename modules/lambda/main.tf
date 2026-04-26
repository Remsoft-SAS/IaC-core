# modules/lambda/main.tf
# Módulo para funciones Lambda con rol IAM interno y políticas dinámicas


locals {
  full_function_name = "${var.function_name}-${var.environment}"
}

# ── Rol de Ejecución IAM ──────────────────────────────────────────────────────

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

  tags = merge(
    {
      Name        = "${local.full_function_name}-role"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Política básica (Logs)
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para VPC (si aplica)
resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Políticas Inline Dinámicas
resource "aws_iam_role_policy" "inline" {
  for_each = { for policy in var.inline_policies : policy.name => policy.policy }

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

# ── Función Lambda ───────────────────────────────────────────────────────────

# Archivo dummy opcional para permitir la creación inicial sin código real
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

  tags = merge(
    {
      Name        = local.full_function_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  # Evitar que cambios manuales en el código o despliegues externos rompan Terraform
  lifecycle {
    ignore_changes = [
      filename,
      s3_key,
      s3_object_version,
      last_modified,
      source_code_hash,
      environment
    ]
  }
}

# Log Group con retención configurable
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.full_function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}


resource "null_resource" "env_vars_merge" {
  count = length(var.environment_variables) > 0 ? 1 : 0

  triggers = {
    tf_vars       = jsonencode(var.environment_variables)
    function_name = local.full_function_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      CURRENT=$(aws lambda get-function-configuration \
        --function-name ${aws_lambda_function.this.function_name} \
        --query 'Environment.Variables' \
        --output json 2>/dev/null || echo '{}')

      MERGED=$(echo "$CURRENT" | jq -c \
        '. + ${jsonencode(var.environment_variables)}')

      aws lambda update-function-configuration \
        --function-name ${aws_lambda_function.this.function_name} \
        --environment "{\"Variables\":$MERGED}" \
        --no-cli-pager > /dev/null
    EOT
  }

  depends_on = [aws_lambda_function.this]
}
