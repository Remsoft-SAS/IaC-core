# stacks/bootstrap/outputs.tf

output "state_bucket_name" {
  description = "Nombre del bucket para el estado de Terraform"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "deployments_bucket_name" {
  description = "Nombre del bucket para despliegues de Lambda"
  value       = aws_s3_bucket.deployments.bucket
}

output "aws_region" {
  description = "AWS Region used"
  value       = var.region
}
