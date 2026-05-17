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
  description = "Base URL to invoke the API"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "stage_name" {
  description = "API stage name"
  value       = aws_api_gateway_stage.this.stage_name
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
