# modules/eventbridge/outputs.tf

output "bus_name" {
  description = "Nombre del EventBridge bus"
  value       = local.bus_name
}

output "bus_arn" {
  description = "ARN del EventBridge bus"
  value       = var.create ? aws_cloudwatch_event_bus.this[0].arn : var.existing_bus_arn
}

output "rule_arns" {
  description = "Map of created EventBridge rule ARNs keyed by rule name."
  value       = { for key, rule in aws_cloudwatch_event_rule.this : key => rule.arn }
}

output "schedule_arns" {
  description = "Map of created EventBridge Scheduler schedule ARNs keyed by schedule name."
  value       = { for key, schedule in aws_scheduler_schedule.this : key => schedule.arn }
}

output "schedule_role_arns" {
  description = "Map of schedule keys to generated or caller-supplied execution role ARNs."
  value       = { for key, schedule in var.schedules : key => schedule.target_role_arn != null ? schedule.target_role_arn : try(aws_iam_role.scheduler_lambda[key].arn, null) }
}
