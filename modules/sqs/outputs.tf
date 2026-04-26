# modules/sqs/outputs.tf

output "queue_name" {
  description = "Final name of the SQS queue"
  value       = aws_sqs_queue.this.name
}

output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.this.arn
}

output "dlq_name" {
  description = "Dead Letter Queue name (if enabled)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "dlq_url" {
  description = "Dead Letter Queue URL (if enabled)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}

output "dlq_arn" {
  description = "Dead Letter Queue ARN (if enabled)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}
