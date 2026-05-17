# modules/api_gateway/main.tf

resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.api_name}-${var.environment}"
  description = "Managed by Remsoft Framework"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge({ Name = "${var.api_name}-${var.environment}" }, var.tags)
}

# ── Cognito Authorizer ───────────────────────────────────────────────────────

resource "aws_api_gateway_authorizer" "cognito" {
  count         = length(var.cognito_user_pool_arns) > 0 ? 1 : 0
  name          = "CognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.this.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = var.cognito_user_pool_arns
}

# ── Resources & Methods ───────────────────────────────────────────────────────

locals {
  # Logic to calculate unique resource paths
  all_paths      = [for ep in var.endpoints : ep.path]
  unique_paths   = distinct(local.all_paths)
  sorted_paths   = sort(local.unique_paths)
  non_root_paths = [for p in local.sorted_paths : p if p != "" && p != "/"]
}

resource "aws_api_gateway_resource" "endpoints" {
  for_each = toset(local.non_root_paths)

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = trimprefix(each.value, "/")
}

resource "aws_api_gateway_method" "endpoints" {
  for_each = { for ep in var.endpoints : "${ep.path}#${ep.http_method}" => ep }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = (each.value.path == "" || each.value.path == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value.path].id
  http_method = each.value.http_method

  # Smart Authorization Logic
  authorization = each.value.authorizer_type
  authorizer_id = each.value.authorizer_type == "COGNITO" ? aws_api_gateway_authorizer.cognito[0].id : (each.value.authorizer_type == "CUSTOM" ? each.value.authorizer_id : null)

  authorization_scopes = each.value.authorizer_type == "COGNITO" ? each.value.authorization_scopes : null
}

resource "aws_api_gateway_integration" "lambda" {
  for_each = { for ep in var.endpoints : "${ep.path}#${ep.http_method}" => ep }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = (each.value.path == "" || each.value.path == "/") ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.endpoints[each.value.path].id
  http_method = aws_api_gateway_method.endpoints[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${each.value.lambda_function_name}-${var.environment}/invocations"
}

# ── CORS Implementation ───────────────────────────────────────────────────────

locals {
  all_unique_paths  = distinct([for ep in var.endpoints : ep.path])
  supported_headers = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent"
}

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

  request_templates = { "application/json" = "{\"statusCode\": 200}" }
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

# ── Deployment & Stages ───────────────────────────────────────────────────────

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  depends_on  = [aws_api_gateway_integration.lambda, aws_api_gateway_integration.options]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.endpoints,
      aws_api_gateway_method.endpoints,
      aws_api_gateway_integration.lambda,
      var.endpoints # Force redeploy on endpoint changes
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
      format          = var.access_log_format
    }
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"
  settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}-${var.environment}"
  retention_in_days = var.log_retention_days
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ── WebSocket API (API Gateway V2) ────────────────────────────────────────────

resource "aws_apigatewayv2_api" "websocket" {
  count                      = var.enable_websocket ? 1 : 0
  name                       = coalesce(var.websocket_api_name, "${var.api_name}-websocket-${var.environment}")
  protocol_type              = "WEBSOCKET"
  route_selection_expression = var.websocket_route_selection_expression
  description                = "Managed by Remsoft Framework"

  tags = merge({ Name = coalesce(var.websocket_api_name, "${var.api_name}-websocket-${var.environment}") }, var.tags)
}

resource "aws_apigatewayv2_integration" "websocket" {
  for_each = var.enable_websocket ? { for r in var.websocket_routes : r.route_key => r } : {}

  api_id                    = aws_apigatewayv2_api.websocket[0].id
  integration_type          = "AWS_PROXY"
  integration_uri           = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${each.value.lambda_function_name}-${var.environment}/invocations"
  content_handling_strategy = "CONVERT_TO_TEXT"
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "websocket" {
  for_each = var.enable_websocket ? { for r in var.websocket_routes : r.route_key => r } : {}

  api_id             = aws_apigatewayv2_api.websocket[0].id
  route_key          = each.key
  authorization_type = each.value.authorization_type
  target             = "integrations/${aws_apigatewayv2_integration.websocket[each.key].id}"
}

resource "aws_apigatewayv2_stage" "websocket" {
  count       = var.enable_websocket ? 1 : 0
  api_id      = aws_apigatewayv2_api.websocket[0].id
  stage_name  = var.environment
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.websocket[0].arn
      format          = var.websocket_access_log_format
    }
  }

  tags = merge({ Name = "${var.api_name}-websocket-${var.environment}" }, var.tags)
}

resource "aws_cloudwatch_log_group" "websocket" {
  count             = var.enable_websocket && var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/websocket/${var.api_name}-${var.environment}"
  retention_in_days = var.log_retention_days
}

# ── Custom Domain — REST API ───────────────────────────────────────────────────

resource "aws_api_gateway_domain_name" "this" {
  count                    = var.custom_domain_name != "" ? 1 : 0
  domain_name              = var.custom_domain_name
  regional_certificate_arn = var.custom_domain_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge({ Name = var.custom_domain_name }, var.tags)
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count       = var.custom_domain_name != "" ? 1 : 0
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
  base_path   = var.custom_domain_base_path != "" ? var.custom_domain_base_path : null
}

# ── Custom Domain — WebSocket API ─────────────────────────────────────────────

resource "aws_apigatewayv2_domain_name" "websocket" {
  count       = var.enable_websocket && var.websocket_custom_domain_name != "" ? 1 : 0
  domain_name = var.websocket_custom_domain_name

  domain_name_configuration {
    certificate_arn = var.websocket_custom_domain_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge({ Name = var.websocket_custom_domain_name }, var.tags)
}

resource "aws_apigatewayv2_api_mapping" "websocket" {
  count       = var.enable_websocket && var.websocket_custom_domain_name != "" ? 1 : 0
  api_id      = aws_apigatewayv2_api.websocket[0].id
  domain_name = aws_apigatewayv2_domain_name.websocket[0].id
  stage       = aws_apigatewayv2_stage.websocket[0].id
}
