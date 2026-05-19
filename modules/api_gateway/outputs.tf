# modules/api_gateway/outputs.tf

output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "API Gateway ARN"
  value       = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "invoke_url" {
  description = "Base URL to invoke the API (null if no endpoints are defined)"
  value       = length(var.endpoints) > 0 ? aws_api_gateway_stage.this[0].invoke_url : null
}

output "stage_name" {
  description = "API stage name (null if no endpoints are defined)"
  value       = length(var.endpoints) > 0 ? aws_api_gateway_stage.this[0].stage_name : null
}

# ── WebSocket Outputs ─────────────────────────────────────────────────────────

output "websocket_api_id" {
  description = "WebSocket API ID (null if enable_websocket = false)"
  value       = var.enable_websocket ? aws_apigatewayv2_api.websocket[0].id : null
}

output "websocket_api_endpoint" {
  description = "WebSocket endpoint URL — wss://... (null if enable_websocket = false)"
  value       = var.enable_websocket ? "${aws_apigatewayv2_api.websocket[0].api_endpoint}/${var.environment}" : null
}

output "websocket_execution_arn" {
  description = "Execution ARN for granting Lambda invoke permissions (null if enable_websocket = false)"
  value       = var.enable_websocket ? aws_apigatewayv2_api.websocket[0].execution_arn : null
}

# ── Custom Domain Outputs ─────────────────────────────────────────────────────

output "custom_domain_regional_domain_name" {
  description = "Regional domain name to use as DNS CNAME/ALIAS target for the REST API custom domain (null if not configured)"
  value       = var.custom_domain_name != "" ? aws_api_gateway_domain_name.this[0].regional_domain_name : null
}

output "custom_domain_hosted_zone_id" {
  description = "Hosted zone ID for the REST API custom domain — use with Route53 alias records (null if not configured)"
  value       = var.custom_domain_name != "" ? aws_api_gateway_domain_name.this[0].regional_zone_id : null
}

output "custom_domain_target" {
  description = "Regional domain name of the REST API custom domain (used as Route53 alias name — null if not configured)"
  value       = var.custom_domain_name != "" ? aws_api_gateway_domain_name.this[0].regional_domain_name : null
}

output "stage_invoke_url" {
  description = "Direct invoke URL of the deployed stage (null if no endpoints are defined)"
  value       = length(var.endpoints) > 0 ? aws_api_gateway_stage.this[0].invoke_url : null
}

output "websocket_custom_domain_target" {
  description = "Target domain name to use as DNS CNAME/ALIAS for the WebSocket custom domain (null if not configured)"
  value       = var.enable_websocket && var.websocket_custom_domain_name != "" ? aws_apigatewayv2_domain_name.websocket[0].domain_name_configuration[0].target_domain_name : null
}

output "websocket_custom_domain_hosted_zone_id" {
  description = "Hosted zone ID for the WebSocket custom domain — use with Route53 alias records (null if not configured)"
  value       = var.enable_websocket && var.websocket_custom_domain_name != "" ? aws_apigatewayv2_domain_name.websocket[0].domain_name_configuration[0].hosted_zone_id : null
}
