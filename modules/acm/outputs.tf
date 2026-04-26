# modules/acm/outputs.tf

output "certificate_arn" {
  description = "ARN del certificado validado"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_domain" {
  description = "Dominio principal del certificado"
  value       = aws_acm_certificate.this.domain_name
}
