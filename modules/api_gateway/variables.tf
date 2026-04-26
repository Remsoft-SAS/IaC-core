# modules/api_gateway/variables.tf

variable "api_name" {
  description = "Base name of the API"
  type        = string
}

variable "description" {
  description = "API Description"
  type        = string
  default     = "Managed by Terraform"
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "endpoint_type" {
  description = "Endpoint type (REGIONAL, EDGE, PRIVATE)"
  type        = string
  default     = "REGIONAL"
}

variable "binary_media_types" {
  description = "List of supported binary media types"
  type        = list(string)
  default     = ["*/*"]
}

variable "endpoints" {
  description = "List of endpoints and their configuration"
  type = list(object({
    path                 = string
    http_method          = string
    authorization        = string
    authorizer_id        = optional(string, null)
    lambda_invoke_arn    = string
    lambda_function_name = string
    api_key_required     = optional(bool, false)
  }))
}

variable "enable_cors" {
  description = "Enable CORS for all endpoints"
  type        = bool
  default     = true
}

variable "cors_allow_origin" {
  description = "Allowed origins for CORS"
  type        = string
  default     = "*"
}

variable "cors_allow_credentials" {
  description = "Indicates if credentials are allowed in CORS"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
  description = "Enable access logs in CloudWatch"
  type        = bool
  default     = false
}

variable "manage_api_gateway_account" {
  description = "If true, configures the global CloudWatch role for the account in this region. Should only be active in one service or base stack."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Log retention days in CloudWatch"
  type        = number
  default     = 7
}

variable "access_log_format" {
  description = "Access log format in JSON"
  type        = string
  default     = "{ \"requestId\":\"$context.requestId\", \"ip\":\"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
}

variable "throttling_burst_limit" {
  description = "Burst request limit"
  type        = number
  default     = 1000
}

variable "throttling_rate_limit" {
  description = "Rate request limit per second"
  type        = number
  default     = 500
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
