# modules/cognito/variables.tf

variable "pool_name" {
  description = "Nombre base del User Pool de Cognito"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "username_attributes" {
  description = "Atributos que pueden usarse para login (phone_number, email)"
  type        = list(string)
  default     = ["phone_number"]
}

variable "password_minimum_length" {
  description = "Longitud mínima de la contraseña"
  type        = number
  default     = 8
}

variable "password_require_lowercase" {
  description = "Requerir minúsculas en la contraseña"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Requerir números en la contraseña"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Requerir símbolos en la contraseña"
  type        = bool
  default     = true
}

variable "password_require_uppercase" {
  description = "Requerir mayúsculas en la contraseña"
  type        = bool
  default     = true
}

variable "temp_password_validity_days" {
  description = "Días de validez para contraseñas temporales"
  type        = number
  default     = 7
}

variable "lambda_pre_signup_arn" {
  description = "ARN de la Lambda para el trigger Pre Sign-up"
  type        = string
  default     = null
}

variable "lambda_define_auth_arn" {
  description = "ARN de la Lambda para el trigger Define Auth Challenge"
  type        = string
  default     = null
}

variable "lambda_create_auth_arn" {
  description = "ARN de la Lambda para el trigger Create Auth Challenge"
  type        = string
  default     = null
}

variable "lambda_verify_auth_arn" {
  description = "ARN de la Lambda para el trigger Verify Auth Challenge Response"
  type        = string
  default     = null
}

variable "lambda_post_confirmation_arn" {
  description = "ARN de la Lambda para el trigger Post Confirmation"
  type        = string
  default     = null
}

variable "explicit_auth_flows" {
  description = "Flujos de autenticación permitidos"
  type        = list(string)
  default     = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
}

variable "access_token_validity_hours" {
  description = "Validez del Access Token en horas"
  type        = number
  default     = 1
}

variable "id_token_validity_hours" {
  description = "Validez del ID Token en horas"
  type        = number
  default     = 1
}

variable "refresh_token_validity_days" {
  description = "Validez del Refresh Token en días"
  type        = number
  default     = 30
}

variable "callback_urls" {
  description = "URLs de callback permitidas"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "URLs de logout permitidas"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
