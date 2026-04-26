# modules/api_gateway/main.tf
# Generic REST API Gateway module — dynamic routes and methods via for_each

locals {
  all_unique_paths = distinct([for ep in var.endpoints : ep.path])
  resource_paths   = [for path in local.all_unique_paths : path if path != "" && path != "/"]

  supported_headers = join(",", [
    "Content-Type",
    "X-Amz-Date",
    "Authorization",
    "X-Api-Key",
    "X-Amz-Security-Token",
    "X-Requested-With",
    "x-business-id",
    "x-api-key",
    "Accept",
    "Origin",
    "sec-ch-ua",
    "sec-ch-ua-mobile",
    "sec-ch-ua-platform"
  ])
}

# ── REST API ─────────────────────────────────────────────────────────────────

resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.api_name}-${var.environment}"
  description = var.description

  binary_media_types = var.binary_media_types

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(
    {
      Name        = "${var.api_name}-${var.environment}"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ── Resources (paths) ─────────────────────────────────────────────────────────

resource "aws_api_gateway_resource" "endpoints" {
  for_each = toset(local.resource_paths)

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value
}

# ── Methods ──────────────────────────────────────────────────────────────────

resource "aws_api_gateway_method" "endpoints" {
  for_each = { for ep in var.endpoints : "${ep.path}#${ep.http_method}" => ep }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = (each.value.path == "" || each.value.path == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value.path].id
  http_method   = each.value.http_method
  authorization = each.value.authorization
  authorizer_id = each.value.authorizer_id

  request_parameters = each.value.api_key_required ? {
    "method.request.header.x-api-key" = true
  } : {}

  api_key_required = each.value.api_key_required
}

# ── Lambda Integrations ──────────────────────────────────────────────────────

resource "aws_api_gateway_integration" "lambda" {
  for_each = { for ep in var.endpoints : "${ep.path}#${ep.http_method}" => ep }

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = (each.value.path == "" || each.value.path == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value.path].id
  http_method             = aws_api_gateway_method.endpoints[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn
}

# ── CORS ─────────────────────────────────────────────────────────────────────

resource "aws_api_gateway_method" "options" {
  for_each = var.enable_cors ? toset(local.all_unique_paths) : []

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = (each.value == "" || each.value == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = var.enable_cors ? toset(local.all_unique_paths) : []

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = (each.value == "" || each.value == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = var.enable_cors ? toset(local.all_unique_paths) : []

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = (each.value == "" || each.value == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = var.enable_cors ? toset(local.all_unique_paths) : []

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = (each.value == "" || each.value == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value].id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = aws_api_gateway_method_response.options[each.value].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'${local.supported_headers}'"
    "method.response.header.Access-Control-Allow-Methods"     = "'GET,POST,PUT,PATCH,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"      = "'${var.cors_allow_origin}'"
    "method.response.header.Access-Control-Allow-Credentials" = var.cors_allow_credentials ? "'true'" : "'false'"
  }
}

# ── Gateway Responses with CORS ───────────────────────────────────────────────

resource "aws_api_gateway_gateway_response" "cors_4xx" {
  count = var.enable_cors ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "'${var.cors_allow_origin}'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'${local.supported_headers}'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'GET,POST,PUT,PATCH,DELETE,OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = var.cors_allow_credentials ? "'true'" : "'false'"
  }
}

resource "aws_api_gateway_gateway_response" "cors_5xx" {
  count = var.enable_cors ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = "'${var.cors_allow_origin}'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'${local.supported_headers}'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'GET,POST,PUT,PATCH,DELETE,OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = var.cors_allow_credentials ? "'true'" : "'false'"
  }
}

# ── Deployment ────────────────────────────────────────────────────────────────

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.options,
    aws_api_gateway_integration_response.options,
    aws_api_gateway_gateway_response.cors_4xx,
    aws_api_gateway_gateway_response.cors_5xx,
  ]

  lifecycle {
    create_before_destroy = true
  }

  # Force redeploy when any API resource changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.this,
      aws_api_gateway_resource.endpoints,
      aws_api_gateway_method.endpoints,
      aws_api_gateway_integration.lambda,
      aws_api_gateway_method.options,
      aws_api_gateway_integration.options,
      aws_api_gateway_method_response.options,
      aws_api_gateway_integration_response.options,
    ]))
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment

  # CloudWatch Logging (optional)
  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
      format          = var.access_log_format
    }
  }

  tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Default throttling for all methods
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }
}

# Log group for access logs
resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ── IAM Role for CloudWatch Logs (Internal) ───────────────────────────────────

resource "aws_iam_role" "cloudwatch" {
  count = var.enable_access_logs ? 1 : 0
  name  = "apigateway-cloudwatch-${var.api_name}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })

  tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count      = var.enable_access_logs ? 1 : 0
  role       = aws_iam_role.cloudwatch[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Note: aws_api_gateway_account is region/account wide.
# To avoid conflicts between multiple services, it's only managed if manage_api_gateway_account is true.
resource "aws_api_gateway_account" "this" {
  count               = (var.enable_access_logs && var.manage_api_gateway_account) ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.cloudwatch[0].arn
}

# ── Lambda Permissions ────────────────────────────────────────────────────────

resource "aws_lambda_permission" "apigw" {
  for_each = { for ep in var.endpoints : "${ep.path}#${ep.http_method}" => ep }

  statement_id  = "AllowAPIGatewayInvoke-${replace(replace(replace(replace(replace(each.key, "#", "-"), "{", ""), "}", ""), "+", "plus"), "/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
