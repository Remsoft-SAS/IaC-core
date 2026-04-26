# modules/cloudfront/outputs.tf

output "distribution_id" {
  description = "ID de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  description = "Nombre de dominio de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_arn" {
  description = "ARN de la distribución de CloudFront"
  value       = aws_cloudfront_distribution.this.arn
}

output "oac_id" {
  description = "ID del Origin Access Control"
  value       = aws_cloudfront_origin_access_control.this.id
}
