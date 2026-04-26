# modules/api_gateway/outputs.tf

output "api_id" {
  description = "ID de la API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "ARN de la API Gateway"
  value       = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  description = "ARN de ejecución de la API Gateway"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "invoke_url" {
  description = "URL base para invocar la API"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "stage_name" {
  description = "Nombre del stage de la API"
  value       = aws_api_gateway_stage.this.stage_name
}
