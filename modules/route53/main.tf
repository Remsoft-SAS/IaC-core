# modules/route53/main.tf
# Módulo para gestionar zonas y registros de Route 53

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(
    {
      Name        = var.domain_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_route53_record" "this" {
  for_each = { for rec in var.records : "${rec.name}_${rec.type}" => rec }

  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl

  records = each.value.records != null ? each.value.records : null

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }
}
