# modules/route53/outputs.tf

output "zone_id" {
  description = "Hosted zone ID"
  value       = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

output "name_servers" {
  description = "List of name servers to configure in the domain registrar"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : null
}

output "records" {
  description = "Map of created records"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}
