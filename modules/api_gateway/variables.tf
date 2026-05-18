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
    authorizer_type      = string       # NONE, COGNITO, CUSTOM
    authorizer_id        = string       # Optional: Custom Authorizer ID
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

# --- Proxy Routes ---
variable "enable_proxy_routes" {
  description = "Automatically create a {proxy+} child resource for each endpoint path, enabling sub-route handling (e.g. /users/{proxy+}). Default false for backwards compatibility."
  type        = bool
  default     = false
}

# --- WebSocket (API Gateway V2) ---
variable "enable_websocket" {
  description = "Enable a WebSocket API (API Gateway V2) alongside the REST API"
  type        = bool
  default     = false
}

variable "websocket_api_name" {
  description = "Name override for the WebSocket API. Defaults to '<api_name>-websocket-<environment>'"
  type        = string
  default     = ""
}

variable "websocket_route_selection_expression" {
  description = "Route selection expression for the WebSocket API"
  type        = string
  default     = "$request.body.action"
}

variable "websocket_routes" {
  description = "List of WebSocket routes. Use standard keys ($connect, $disconnect, $default) or custom action names."
  type = list(object({
    route_key            = string # e.g. "$connect", "$disconnect", "$default", "sendMessage"
    lambda_function_name = string
    authorization_type   = string # NONE, AWS_IAM, CUSTOM, JWT
  }))
  default = []
}

variable "websocket_enable_access_logs" {
  description = "Enable CloudWatch access logs for the WebSocket API. Requires a CloudWatch Logs role ARN configured at account level (aws_api_gateway_account). Defaults to false to avoid deployment errors on accounts without it."
  type        = bool
  default     = false
}

variable "websocket_access_log_format" {
  description = "Log format for WebSocket API access logs (used only if websocket_enable_access_logs = true)"
  type        = string
  default     = "{ \"requestId\":\"$context.requestId\", \"connectionId\":\"$context.connectionId\", \"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\", \"integrationError\":\"$context.integrationErrorMessage\" }"
}

# --- Custom Domain — REST API ---
variable "custom_domain_name" {
  description = "Custom domain name for the REST API (e.g. api.example.com). Leave empty to skip."
  type        = string
  default     = ""
}

variable "custom_domain_certificate_arn" {
  description = "ACM certificate ARN for the REST API custom domain (must be in the same region)"
  type        = string
  default     = ""
}

variable "custom_domain_base_path" {
  description = "Base path mapping for the REST API custom domain. Empty string maps to the root path."
  type        = string
  default     = ""
}

# --- Custom Domain — WebSocket API ---
variable "websocket_custom_domain_name" {
  description = "Custom domain name for the WebSocket API (e.g. ws.example.com). Leave empty to skip."
  type        = string
  default     = ""
}

variable "websocket_custom_domain_certificate_arn" {
  description = "ACM certificate ARN for the WebSocket custom domain (must be in the same region)"
  type        = string
  default     = ""
}
