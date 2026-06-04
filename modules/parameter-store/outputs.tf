# modules/parameter-store/outputs.tf

locals {
  all_params = merge(
    { for name, p in aws_ssm_parameter.standard : name => p },
    { for name, p in aws_ssm_parameter.external : name => p }
  )
}

output "parameters" {
  description = "Map of created parameters (name => arn)"
  value       = { for name, p in local.all_params : name => p.arn }
}

output "parameter_names" {
  description = "List of names of the created parameters"
  value       = [for name, p in local.all_params : name]
}

output "parameter_arns" {
  description = "List of ARNs of the created parameters"
  value       = [for name, p in local.all_params : p.arn]
}

output "parameter_versions" {
  description = "Map of created parameters (name => version)"
  value       = { for name, p in local.all_params : name => p.version }
}
