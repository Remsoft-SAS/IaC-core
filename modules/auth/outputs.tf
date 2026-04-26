# modules/auth/outputs.tf

output "user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Endpoint del User Pool de Cognito"
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_client_id" {
  description = "ID del User Pool Client"
  value       = aws_cognito_user_pool_client.this.id
}

output "user_pool_client_secret" {
  description = "Secret del User Pool Client (si aplica)"
  value       = aws_cognito_user_pool_client.this.client_secret
  sensitive   = true
}
