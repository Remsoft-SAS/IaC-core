# modules/cognito/main.tf

# --- Data Discovery ---
data "aws_route53_zone" "selected" {
  count = var.domain_name != "" ? 1 : 0
  name  = "${var.domain_name}."
}

data "aws_acm_certificate" "wildcard" {
  count       = var.domain_name != "" ? 1 : 0
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}

# --- User Pool ---
resource "aws_cognito_user_pool" "this" {
  name = "${var.pool_name}-${var.environment}"

  username_attributes      = var.username_attributes
  auto_verified_attributes = []

  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temp_password_validity_days
  }

  lambda_config {
    pre_sign_up                    = var.lambda_pre_signup_arn
    define_auth_challenge          = var.lambda_define_auth_arn
    create_auth_challenge          = var.lambda_create_auth_arn
    verify_auth_challenge_response = var.lambda_verify_auth_arn
    post_confirmation              = var.lambda_post_confirmation_arn
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 1
    }
  }

  deletion_protection = var.environment == "production" ? "ACTIVE" : "INACTIVE"

  tags = merge(
    {
      Name        = "${var.pool_name}-${var.environment}"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  lifecycle {
    ignore_changes = [schema]
  }
}

# --- Custom Domain & DNS ---

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

# --- Lambda Permissions (Automated) ---

resource "aws_lambda_permission" "triggers" {
  for_each = {
    for k, v in {
      "define"     = var.lambda_define_auth_arn
      "create"     = var.lambda_create_auth_arn
      "verify"     = var.lambda_verify_auth_arn
      "pre-signup" = var.lambda_pre_signup_arn
    } : k => v if v != null
  }

  statement_id  = "AllowExecutionFromCognito-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", each.value), length(split(":", each.value)) - 1)
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}

# --- Social Providers ---

resource "aws_cognito_identity_provider" "google" {
  count         = var.google_client_id != "" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email profile openid"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    attributes_url_language = "en"
    authorize_url           = "https://accounts.google.com/o/oauth2/v2/auth"
    token_url               = "https://www.googleapis.com/oauth2/v4/token"
    attributes_url          = "https://openidconnect.googleapis.com/v1/userinfo"
    jwks_uri                = "https://www.googleapis.com/oauth2/v3/certs"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
  }
}

resource "aws_cognito_identity_provider" "microsoft" {
  count         = var.microsoft_client_id != "" ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Microsoft"
  provider_type = "OIDC"

  provider_details = {
    client_id                     = var.microsoft_client_id
    client_secret                 = var.microsoft_client_secret
    attributes_request_method     = "GET"
    oidc_issuer                   = "https://login.microsoftonline.com/${var.microsoft_tenant_id}/v2.0"
    authorize_scopes              = "openid email profile"
    setup_multi_issuer_termination = "false"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
  }
}

# --- Client ---

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

  prevent_user_existence_errors = "ENABLED"

  supported_identity_providers = concat(
    ["COGNITO"],
    var.google_client_id != "" ? ["Google"] : [],
    var.microsoft_client_id != "" ? ["Microsoft"] : []
  )

  callback_urls = length(var.callback_urls) > 0 ? var.callback_urls : null
  logout_urls   = length(var.logout_urls) > 0 ? var.logout_urls : null

  allowed_oauth_flows_user_pool_client = length(var.callback_urls) > 0
  allowed_oauth_flows                  = length(var.callback_urls) > 0 ? ["code"] : []
  allowed_oauth_scopes                 = length(var.callback_urls) > 0 ? ["openid", "email", "phone"] : []

  depends_on = [
    aws_cognito_identity_provider.google,
    aws_cognito_identity_provider.microsoft
  ]
}
