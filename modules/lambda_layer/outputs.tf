# modules/lambda_layer/outputs.tf

output "arn" {
  description = "Full ARN of the Lambda Layer version (includes version number) — use this in aws_lambda_function.layers"
  value       = aws_lambda_layer_version.this.arn
}

output "layer_arn" {
  description = "ARN of the Lambda Layer without version number"
  value       = aws_lambda_layer_version.this.layer_arn
}

output "layer_name" {
  description = "Name of the Lambda Layer as created in AWS"
  value       = aws_lambda_layer_version.this.layer_name
}

output "version" {
  description = "Published version number of the layer"
  value       = aws_lambda_layer_version.this.version
}

output "created_date" {
  description = "Date the layer version was created"
  value       = aws_lambda_layer_version.this.created_date
}

output "source_code_size" {
  description = "Size of the layer zip in bytes"
  value       = aws_lambda_layer_version.this.source_code_size
}

output "compatible_runtimes" {
  description = "Runtimes compatible with this layer version"
  value       = aws_lambda_layer_version.this.compatible_runtimes
}

output "compatible_architectures" {
  description = "CPU architectures compatible with this layer version"
  value       = aws_lambda_layer_version.this.compatible_architectures
}

output "signing_job_arn" {
  description = "ARN of the signing job (only present if the layer was signed)"
  value       = aws_lambda_layer_version.this.signing_job_arn
}

output "signing_profile_version_arn" {
  description = "ARN of the signing profile version (only present if the layer was signed)"
  value       = aws_lambda_layer_version.this.signing_profile_version_arn
}
