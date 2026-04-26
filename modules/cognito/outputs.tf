# modules/cognito/outputs.tf

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.this.id
}

output "user_pool_client_secret" {
  description = "Cognito User Pool Client Secret (if applicable)"
  value       = aws_cognito_user_pool_client.this.client_secret
  sensitive   = true
}
