# modules/eventbridge/outputs.tf

output "bus_name" {
  description = "Nombre del EventBridge bus"
  value       = var.create ? aws_cloudwatch_event_bus.this[0].name : var.existing_bus_arn
}

output "bus_arn" {
  description = "ARN del EventBridge bus"
  value       = var.create ? aws_cloudwatch_event_bus.this[0].arn : var.existing_bus_arn
}
