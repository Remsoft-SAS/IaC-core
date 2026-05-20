# modules/lambda_layer/main.tf

resource "aws_lambda_layer_version" "this" {
  layer_name   = "${var.layer_name}-${var.environment}"
  description  = var.description != "" ? var.description : "Managed by Remsoft Framework"
  license_info = var.license_info
  skip_destroy = var.skip_destroy

  # Source: local file
  filename         = var.filename
  source_code_hash = var.source_code_hash

  # Source: S3
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  compatible_runtimes      = length(var.compatible_runtimes) > 0 ? var.compatible_runtimes : null
  compatible_architectures = length(var.compatible_architectures) > 0 ? var.compatible_architectures : null
}

# ── Cross-account permissions ─────────────────────────────────────────────────

resource "aws_lambda_layer_version_permission" "this" {
  for_each = { for p in var.layer_permissions : p.statement_id => p }

  layer_name      = aws_lambda_layer_version.this.layer_name
  version_number  = aws_lambda_layer_version.this.version
  statement_id    = each.value.statement_id
  action          = "lambda:GetLayerVersion"
  principal       = each.value.principal
  organization_id = each.value.organization_id
}
