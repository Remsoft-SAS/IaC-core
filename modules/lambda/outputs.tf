# modules/lambda/outputs.tf

output "function_name" {
  description = "Final name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_name" {
  description = "Name of the IAM execution role"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN of the IAM execution role"
  value       = aws_iam_role.this.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.this.arn
}
