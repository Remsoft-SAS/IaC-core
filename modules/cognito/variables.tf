# modules/cognito/variables.tf

variable "pool_name" {
  description = "Base name of the Cognito User Pool"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "username_attributes" {
  description = "Attributes that can be used for login (phone_number, email)"
  type        = list(string)
  default     = ["phone_number"]
}

variable "password_minimum_length" {
  description = "Minimum password length"
  type        = number
  default     = 8
}

variable "password_require_lowercase" {
  description = "Require lowercase in password"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Require numbers in password"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Require symbols in password"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Require uppercase in password"
  type        = bool
  default     = true
}

variable "temp_password_validity_days" {
  description = "Days of validity for temporary passwords"
  type        = number
  default     = 7
}

# --- Triggers ---
variable "lambda_pre_signup_arn" {
  description = "ARN of the Lambda for Pre Sign-up trigger"
  type        = string
  default     = null
}

variable "lambda_define_auth_arn" {
  description = "ARN of the Lambda for Define Auth Challenge trigger"
  type        = string
  default     = null
}

variable "lambda_create_auth_arn" {
  description = "ARN of the Lambda for Create Auth Challenge trigger"
  type        = string
  default     = null
}

variable "lambda_verify_auth_arn" {
  description = "ARN of the Lambda for Verify Auth Challenge Response trigger"
  type        = string
  default     = null
}

variable "lambda_post_confirmation_arn" {
  description = "ARN of the Lambda for Post Confirmation trigger"
  type        = string
  default     = null
}

# --- OAuth & Social ---
variable "callback_urls" {
  description = "Allowed callback URLs"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "Allowed logout URLs"
  type        = list(string)
  default     = []
}

variable "google_client_id" {
  description = "Google Client ID for Social Login"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google Client Secret for Social Login"
  type        = string
  default     = ""
  sensitive   = true
}

variable "microsoft_client_id" {
  description = "Microsoft Client ID for Social Login"
  type        = string
  default     = ""
}

variable "microsoft_client_secret" {
  description = "Microsoft Client Secret for Social Login"
  type        = string
  default     = ""
  sensitive   = true
}

variable "microsoft_tenant_id" {
  description = "Microsoft Tenant ID (defaults to common for multi-tenant)"
  type        = string
  default     = "common"
}

variable "explicit_auth_flows" {
  description = "Allowed authentication flows"
  type        = list(string)
  default     = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
}

variable "access_token_validity_hours" {
  description = "Access Token validity in hours"
  type        = number
  default     = 1
}

variable "id_token_validity_hours" {
  description = "ID Token validity in hours"
  type        = number
  default     = 1
}

variable "refresh_token_validity_days" {
  description = "Refresh Token validity in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
