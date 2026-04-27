# modules/api_gateway/variables.tf

variable "api_name" {
  description = "Name of the REST API"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "endpoints" {
  description = "List of API endpoints with path, method, lambda name, and optional authorizer"
  type = list(object({
    path                 = string
    http_method          = string
    lambda_function_name = string
    authorizer_type      = string # NONE, COGNITO, CUSTOM
    authorizer_id        = string # Optional: Custom Authorizer ID
    authorization_scopes = list(string) # Optional: OAuth Scopes
  }))
}

# --- Cognito Security ---
variable "cognito_user_pool_arns" {
  description = "List of Cognito User Pool ARNs for the authorizer"
  type        = list(string)
  default     = []
}

# --- CORS ---
variable "enable_cors" {
  description = "Enable CORS for all endpoints"
  type        = bool
  default     = true
}

variable "cors_allow_origin" {
  description = "Value for Access-Control-Allow-Origin header"
  type        = string
  default     = "*"
}

variable "cors_allow_credentials" {
  description = "Value for Access-Control-Allow-Credentials header"
  type        = bool
  default     = false
}

# --- Logs & Monitoring ---
variable "enable_access_logs" {
  description = "Enable CloudWatch Access Logs"
  type        = bool
  default     = true
}

variable "access_log_format" {
  description = "Custom format for access logs"
  type        = string
  default     = "{ \"requestId\":\"$context.requestId\", \"ip\":\"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 7
}

variable "manage_api_gateway_account" {
  description = "Whether to manage the account-wide API Gateway CloudWatch role"
  type        = bool
  default     = false
}

# --- Throttling ---
variable "throttling_burst_limit" {
  description = "Maximum burst limit for throttling"
  type        = number
  default     = 500
}

variable "throttling_rate_limit" {
  description = "Maximum rate limit for throttling"
  type        = number
  default     = 1000
}

variable "tags" {
  description = "Additional tags for the resources"
  type        = map(string)
  default     = {}
}
