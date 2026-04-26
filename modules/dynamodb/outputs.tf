# modules/dynamodb/outputs.tf

output "table_name" {
  description = "Final name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "DynamoDB Stream ARN (if enabled)"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "DynamoDB Stream label"
  value       = aws_dynamodb_table.this.stream_label
}
