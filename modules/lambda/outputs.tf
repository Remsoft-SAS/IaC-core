# modules/lambda/outputs.tf

output "function_name" {
  description = "Nombre final de la función Lambda"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN de la función Lambda"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_name" {
  description = "Nombre del rol IAM de ejecución"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN del rol IAM de ejecución"
  value       = aws_iam_role.this.arn
}

output "log_group_name" {
  description = "Nombre del CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN del CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.arn
}
