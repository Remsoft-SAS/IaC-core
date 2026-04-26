# modules/acm/outputs.tf

output "certificate_arn" {
  description = "ARN of the validated certificate"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain" {
  description = "Primary domain of the certificate"
  value       = aws_acm_certificate.this.domain_name
}
