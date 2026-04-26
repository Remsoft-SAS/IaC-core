# modules/sqs/outputs.tf

output "queue_name" {
  description = "Nombre final de la cola SQS"
  value       = aws_sqs_queue.this.name
}

output "queue_url" {
  description = "URL de la cola SQS"
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "ARN de la cola SQS"
  value       = aws_sqs_queue.this.arn
}

output "dlq_name" {
  description = "Nombre de la Dead Letter Queue (si está habilitada)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "dlq_url" {
  description = "URL de la Dead Letter Queue (si está habilitada)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}

output "dlq_arn" {
  description = "ARN de la Dead Letter Queue (si está habilitada)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}
