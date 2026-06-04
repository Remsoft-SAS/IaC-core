# modules/parameter-store/main.tf
# Module to manage parameters in AWS Systems Manager Parameter Store

locals {
  # Parameters managed fully by Terraform (value tracked)
  standard_params = { for p in var.parameters : p.name => p if !p.ignore_value_changes }

  # Parameters whose value is managed externally (e.g. rotated secrets)
  # Terraform creates them but ignores future value changes
  external_params = { for p in var.parameters : p.name => p if p.ignore_value_changes }
}

# ── Standard Parameters (Terraform-managed value) ─────────────────────────────

resource "aws_ssm_parameter" "standard" {
  for_each = local.standard_params

  name        = each.value.name
  value       = each.value.value
  type        = each.value.type
  description = each.value.description
  key_id      = each.value.type == "SecureString" ? each.value.key_id : null
  data_type   = each.value.data_type
  tier        = length(each.value.value) > 4096 ? "Advanced" : coalesce(each.value.tier, "Standard")

  tags = merge(
    {
      Name        = each.value.name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    each.value.tags
  )
}

# ── External Parameters (value managed outside Terraform) ─────────────────────

resource "aws_ssm_parameter" "external" {
  for_each = local.external_params

  name        = each.value.name
  value       = each.value.value
  type        = each.value.type
  description = each.value.description
  key_id      = each.value.type == "SecureString" ? each.value.key_id : null
  data_type   = each.value.data_type
  tier        = length(each.value.value) > 4096 ? "Advanced" : coalesce(each.value.tier, "Standard")

  tags = merge(
    {
      Name        = each.value.name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    each.value.tags
  )

  lifecycle {
    ignore_changes = [value]
  }
}
