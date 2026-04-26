# modules/cognito/main.tf
# Módulo genérico para Cognito User Pool totalmente configurable

resource "aws_cognito_user_pool" "this" {
  name = "${var.pool_name}-${var.environment}"

  # Atributos de login — teléfono requerido, email opcional
  username_attributes      = var.username_attributes
  auto_verified_attributes = [] # Las Lambdas de trigger controlan la verificación

  # Política de contraseñas configurable
  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temp_password_validity_days
  }

  # Triggers de Lambda para flujo personalizado
  lambda_config {
    pre_sign_up                    = var.lambda_pre_signup_arn
    define_auth_challenge          = var.lambda_define_auth_arn
    create_auth_challenge          = var.lambda_create_auth_arn
    verify_auth_challenge_response = var.lambda_verify_auth_arn
    post_confirmation               = var.lambda_post_confirmation_arn
  }

  # Configuración de cuenta
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 1
    }
  }

  # Prevenir borrado accidental en producción
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
    # Schema no se puede modificar después de crear — ignorar cambios
    ignore_changes = [schema]
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.pool_name}-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.this.id

  # Solo flujos de auth necesarios para OTP/Magic Link
  explicit_auth_flows = var.explicit_auth_flows

  # Token validity
  access_token_validity  = var.access_token_validity_hours
  id_token_validity      = var.id_token_validity_hours
  refresh_token_validity = var.refresh_token_validity_days

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"

  # Callback URLs para OAuth (opcional)
  callback_urls = length(var.callback_urls) > 0 ? var.callback_urls : null
  logout_urls   = length(var.logout_urls) > 0 ? var.logout_urls : null

  allowed_oauth_flows_user_pool_client = length(var.callback_urls) > 0
  allowed_oauth_flows                  = length(var.callback_urls) > 0 ? ["code"] : []
  allowed_oauth_scopes                 = length(var.callback_urls) > 0 ? ["openid", "email", "phone"] : []
}
