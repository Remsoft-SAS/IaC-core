# modules/parameter-store/main.tf
# Módulo para gestionar parámetros en AWS Systems Manager Parameter Store

resource "aws_ssm_parameter" "this" {
  for_each = { for param in var.parameters : param.name => param }

  name        = each.value.name
  value       = each.value.value
  type        = each.value.type
  description = each.value.description
  key_id      = each.value.type == "SecureString" ? each.value.key_id : null
  overwrite   = each.value.overwrite

  # Auto-detectar tier según el tamaño del valor
  tier = length(each.value.value) > 4096 ? "Advanced" : coalesce(each.value.tier, "Standard")

  tags = merge(
    {
      Name        = each.value.name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    each.value.tags
  )

  lifecycle {
    # Ignorar cambios al valor para parámetros marcados como externos
    # (manejados fuera de Terraform, como secretos rotados manualmente)
    ignore_changes = []
  }
}
