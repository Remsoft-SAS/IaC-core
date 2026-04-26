# modules/parameter-store/outputs.tf

output "parameters" {
  description = "Map of created parameters (name => arn)"
  value       = { for name, param in aws_ssm_parameter.this : name => param.arn }
}

output "parameter_names" {
  description = "List of names of the created parameters"
  value       = [for name, param in aws_ssm_parameter.this : name]
}

output "parameter_arns" {
  description = "List of ARNs of the created parameters"
  value       = [for name, param in aws_ssm_parameter.this : param.arn]
}
