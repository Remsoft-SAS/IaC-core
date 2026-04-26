# modules/route53/outputs.tf

output "zone_id" {
  description = "ID de la zona hospedada"
  value       = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

output "name_servers" {
  description = "Lista de servidores de nombres (Name Servers) para configurar en Hostinger"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : null
}

output "records" {
  description = "Mapa de registros creados"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}
