# modules/dynamodb/outputs.tf

output "table_name" {
  description = "Nombre final de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID de la tabla DynamoDB"
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN del DynamoDB Stream (si está habilitado)"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "Label del DynamoDB Stream"
  value       = aws_dynamodb_table.this.stream_label
}
