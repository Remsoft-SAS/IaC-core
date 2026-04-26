# stacks/dns-certificates/outputs.tf

output "zone_id" {
  description = "ID de la zona alojada en Route 53"
  value       = module.route53.zone_id
}

output "name_servers" {
  description = "Servidores de nombres (NS) para configurar en el registrador (Hostinger)"
  value       = module.route53.name_servers
}

output "certificate_arn" {
  description = "ARN del certificado SSL generado"
  value       = module.acm.certificate_arn
}
