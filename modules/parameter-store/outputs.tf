# modules/parameter-store/outputs.tf

output "parameters" {
  description = "Mapa de parámetros creados (nombre => arn)"
  value       = { for name, param in aws_ssm_parameter.this : name => param.arn }
}

output "parameter_names" {
  description = "Lista de nombres de los parámetros creados"
  value       = [for name, param in aws_ssm_parameter.this : name]
}

output "parameter_arns" {
  description = "Lista de ARNs de los parámetros creados"
  value       = [for name, param in aws_ssm_parameter.this : param.arn]
}
