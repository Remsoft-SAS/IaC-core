# modules/cognito/variables.tf

variable "pool_name" {
  description = "Base name for the User Pool"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

# --- Schema & Attributes ---
variable "username_attributes" {
  description = "Attributes used for login (email, phone_number)"
  type        = list(string)
  default     = ["email"]
}

variable "custom_attributes" {
  description = "List of custom attributes to add to the schema"
  type = list(object({
    name                = string
    attribute_data_type = string # String, Number, DateTime, Boolean
    mutable             = bool
    required            = bool
    string_attribute_constraints = optional(object({
      min_length = number
      max_length = number
    }))
  }))
  default = []
}

# --- Password Policy ---
variable "password_minimum_length" {
  type    = number
  default = 8
}
variable "password_require_lowercase" {
  type    = bool
  default = true
}
variable "password_require_numbers" {
  type    = bool
  default = true
}
variable "password_require_symbols" {
  type    = bool
  default = true
}
variable "password_require_uppercase" {
  type    = bool
  default = true
}
variable "temp_password_validity_days" {
  type    = number
  default = 7
}

# --- MFA & Security ---
variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OFF"
}

variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "OFF"
}

# --- Triggers ---
variable "lambda_pre_signup_arn" {
  type    = string
  default = null
}
variable "lambda_define_auth_arn" {
  type    = string
  default = null
}
variable "lambda_create_auth_arn" {
  type    = string
  default = null
}
variable "lambda_verify_auth_arn" {
  type    = string
  default = null
}
variable "lambda_post_confirmation_arn" {
  type    = string
  default = null
}
variable "lambda_user_migration_arn" {
  description = "ARN for User Migration trigger"
  type        = string
  default     = null
}

# --- Trigger Enablers (To solve "known after apply" count issues) ---
variable "enable_pre_signup" {
  type    = bool
  default = false
}
variable "enable_define_auth" {
  type    = bool
  default = false
}
variable "enable_create_auth" {
  type    = bool
  default = false
}
variable "enable_verify_auth" {
  type    = bool
  default = false
}
variable "enable_migration" {
  type    = bool
  default = false
}
variable "enable_post_confirmation" {
  type    = bool
  default = false
}

# --- DNS & Domain ---
variable "domain_name" {
  description = "Root domain for Route53 and ACM (e.g. remsoft.io)"
  type        = string
  default     = ""
}
variable "custom_domain" {
  description = "Custom auth domain (e.g. auth.remsoft.io)"
  type        = string
  default     = ""
}

# --- Providers (Social) ---
variable "google_client_id" {
  type    = string
  default = ""
}
variable "google_client_secret" {
  type      = string
  default   = ""
  sensitive = true
}

variable "microsoft_client_id" {
  type    = string
  default = ""
}
variable "microsoft_client_secret" {
  type      = string
  default   = ""
  sensitive = true
}
variable "microsoft_tenant_id" {
  type    = string
  default = "common"
}

variable "facebook_client_id" {
  type    = string
  default = ""
}
variable "facebook_client_secret" {
  type      = string
  default   = ""
  sensitive = true
}

# --- Client Config ---
variable "callback_urls" {
  type    = list(string)
  default = []
}
variable "logout_urls" {
  type    = list(string)
  default = []
}

variable "access_token_validity_hours" {
  type    = number
  default = 1
}
variable "id_token_validity_hours" {
  type    = number
  default = 1
}
variable "refresh_token_validity_days" {
  type    = number
  default = 30
}

variable "explicit_auth_flows" {
  description = "Explicit auth flows for the app client"
  type        = list(string)
  default     = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
}

variable "prevent_user_existence_errors" {
  description = "If true, Cognito returns a generic error for non-existent users. If false, it returns UserNotFoundException."
  type        = bool
  default     = true # Por defecto mantenemos el estándar de seguridad de AWS
}

variable "tags" {
  type    = map(string)
  default = {}
}
