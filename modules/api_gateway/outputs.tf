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
