# modules/parameter-store/main.tf
# Module to manage parameters in AWS Systems Manager Parameter Store

resource "aws_ssm_parameter" "this" {
  for_each = { for param in var.parameters : param.name => param }

  name        = each.value.name
  value       = each.value.value
  type        = each.value.type
  description = each.value.description
  key_id      = each.value.type == "SecureString" ? each.value.key_id : null
  overwrite   = each.value.overwrite

  # Auto-detect tier based on value length
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
    # Ignore changes to the value for parameters marked as external
    # (managed outside Terraform, like manually rotated secrets)
    ignore_changes = []
  }
}
