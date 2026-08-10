# modules/step_functions/outputs.tf

output "state_machine_arn" {
  description = "ARN de la State Machine"
  value       = aws_sfn_state_machine.this.arn
}

output "state_machine_name" {
  description = "Nombre de la State Machine"
  value       = aws_sfn_state_machine.this.name
}

output "role_arn" {
  description = "ARN del IAM role de ejecucion de la State Machine"
  value       = aws_iam_role.this.arn
}
