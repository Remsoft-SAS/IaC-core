# modules/cognito/main.tf
# Advanced User Pool with Smart Identity Integration

# ── Data Discovery ──────────────────────────────────────────────────────────

data "aws_route53_zone" "selected" {
  count = var.domain_name != "" ? 1 : 0
  name  = "${var.domain_name}."
}

data "aws_acm_certificate" "wildcard" {
  count       = var.custom_domain != "" ? 1 : 0
  domain      = var.domain_name != "" ? var.domain_name : join(".", slice(split(".", var.custom_domain), 1, length(split(".", var.custom_domain))))
  statuses    = ["ISSUED", "PENDING_VALIDATION"]
  most_recent = true
}

# ── User Pool ────────────────────────────────────────────────────────────────

resource "aws_cognito_user_pool" "this" {
  name = "${var.pool_name}-${var.environment}"

  username_attributes      = var.username_attributes
  auto_verified_attributes = contains(var.username_attributes, "email") ? ["email"] : []

  # Password Security
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temp_password_validity_days
  }

  # MFA Configuration
  mfa_configuration = var.mfa_configuration

  dynamic "software_token_mfa_configuration" {
    for_each = var.mfa_configuration != "OFF" ? [1] : []
    content {
      enabled = true
    }
  }

  # Advanced Security
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Smart Trigger Integration
  lambda_config {
    pre_sign_up                    = var.lambda_pre_signup_arn
    define_auth_challenge          = var.lambda_define_auth_arn
    create_auth_challenge          = var.lambda_create_auth_arn
    verify_auth_challenge_response = var.lambda_verify_auth_arn
    post_confirmation              = var.lambda_post_confirmation_arn
    user_migration                 = var.lambda_user_migration_arn
  }

  # Dynamic Attributes (Schema)
  dynamic "schema" {
    for_each = var.custom_attributes
    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      mutable             = schema.value.mutable
      required            = schema.value.required

      dynamic "string_attribute_constraints" {
        for_each = schema.value.attribute_data_type == "String" && schema.value.string_attribute_constraints != null ? [1] : []
        content {
          min_length = schema.value.string_attribute_constraints.min_length
          max_length = schema.value.string_attribute_constraints.max_length
        }
      }
    }
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  deletion_protection = var.environment == "production" ? "ACTIVE" : "INACTIVE"
  tags                = merge({ Name = "${var.pool_name}-${var.environment}" }, var.tags)

  lifecycle {
    ignore_changes = [schema]
  }
}

# ── DNS & Domain ─────────────────────────────────────────────────────────────

resource "aws_cognito_user_pool_domain" "custom" {
  count           = var.custom_domain != "" ? 1 : 0
  domain          = var.custom_domain
  certificate_arn = data.aws_acm_certificate.wildcard[0].arn
  user_pool_id    = aws_cognito_user_pool.this.id
}

resource "aws_route53_record" "auth_alias" {
  count   = var.custom_domain != "" ? 1 : 0
  name    = aws_cognito_user_pool_domain.custom[0].domain
  type    = "A"
  zone_id = data.aws_route53_zone.selected[0].zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.custom[0].cloudfront_distribution
    zone_id                = "Z2FDTNDATAQYW2"
  }
}

# ── Social Identity Providers ────────────────────────────────────────────────

resource "aws_cognito_identity_provider" "google" {
  count         = var.google_client_id != "" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"
  provider_details = {
    authorize_scopes = "email profile openid"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }
  attribute_mapping = { email = "email", username = "sub", name = "name" }
}

resource "aws_cognito_identity_provider" "microsoft" {
  count         = var.microsoft_client_id != "" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Microsoft"
  provider_type = "OIDC"
  provider_details = {
    client_id        = var.microsoft_client_id
    client_secret    = var.microsoft_client_secret
    oidc_issuer      = "https://login.microsoftonline.com/${var.microsoft_tenant_id}/v2.0"
    authorize_scopes = "openid email profile"
  }
  attribute_mapping = { email = "email", username = "sub", name = "name" }
}

resource "aws_cognito_identity_provider" "facebook" {
  count         = var.facebook_client_id != "" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Facebook"
  provider_type = "Facebook"
  provider_details = {
    client_id        = var.facebook_client_id
    client_secret    = var.facebook_client_secret
    authorize_scopes = "email,public_profile"
    api_version      = "v17.0"
  }
  attribute_mapping = { email = "email", username = "id", name = "name" }
}

# ── App Client ───────────────────────────────────────────────────────────────

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.pool_name}-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = var.explicit_auth_flows

  access_token_validity  = var.access_token_validity_hours
  id_token_validity      = var.id_token_validity_hours
  refresh_token_validity = var.refresh_token_validity_days
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  prevent_user_existence_errors = var.prevent_user_existence_errors ? "ENABLED" : "LEGACY"

  supported_identity_providers = concat(
    ["COGNITO"],
    var.google_client_id != "" ? ["Google"] : [],
    var.microsoft_client_id != "" ? ["Microsoft"] : [],
    var.facebook_client_id != "" ? ["Facebook"] : []
  )

  callback_urls                        = length(var.callback_urls) > 0 ? var.callback_urls : null
  logout_urls                          = length(var.logout_urls) > 0 ? var.logout_urls : null
  allowed_oauth_flows_user_pool_client = length(var.callback_urls) > 0
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "phone", "profile"]

  depends_on = [aws_cognito_identity_provider.google, aws_cognito_identity_provider.microsoft, aws_cognito_identity_provider.facebook]
}

# ── Permissions (Automated) ──────────────────────────────────────────────────

# Individual permissions to avoid for_each "known after apply" issues
resource "aws_lambda_permission" "pre_signup" {
  count         = var.enable_pre_signup ? 1 : 0
  statement_id  = "AllowExecutionFromCognito-PreSignUp"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_pre_signup_arn), length(split(":", var.lambda_pre_signup_arn)) - 1)
  principal     = "cognito-idp.amazonaws.com"
}

resource "aws_lambda_permission" "define_auth" {
  count         = var.enable_define_auth ? 1 : 0
  statement_id  = "AllowExecutionFromCognito-DefineAuth"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_define_auth_arn), length(split(":", var.lambda_define_auth_arn)) - 1)
  principal     = "cognito-idp.amazonaws.com"
}

resource "aws_lambda_permission" "create_auth" {
  count         = var.enable_create_auth ? 1 : 0
  statement_id  = "AllowExecutionFromCognito-CreateAuth"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_create_auth_arn), length(split(":", var.lambda_create_auth_arn)) - 1)
  principal     = "cognito-idp.amazonaws.com"
}

resource "aws_lambda_permission" "verify_auth" {
  count         = var.enable_verify_auth ? 1 : 0
  statement_id  = "AllowExecutionFromCognito-VerifyAuth"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_verify_auth_arn), length(split(":", var.lambda_verify_auth_arn)) - 1)
  principal     = "cognito-idp.amazonaws.com"
}

resource "aws_lambda_permission" "migration" {
  count         = var.enable_migration ? 1 : 0
  statement_id  = "AllowExecutionFromCognito-Migration"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", var.lambda_user_migration_arn), length(split(":", var.lambda_user_migration_arn)) - 1)
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}
