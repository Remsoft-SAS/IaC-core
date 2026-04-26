# modules/api_gateway/variables.tf

variable "api_name" {
  description = "Nombre base de la API"
  type        = string
}

variable "description" {
  description = "Descripción de la API"
  type        = string
  default     = "Managed by Terraform"
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "endpoint_type" {
  description = "Tipo de endpoint (REGIONAL, EDGE, PRIVATE)"
  type        = string
  default     = "REGIONAL"
}

variable "binary_media_types" {
  description = "Lista de binary media types soportados"
  type        = list(string)
  default     = ["*/*"]
}

variable "endpoints" {
  description = "Lista de endpoints y su configuración"
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
  description = "Habilitar CORS para todos los endpoints"
  type        = bool
  default     = true
}

variable "cors_allow_origin" {
  description = "Orígenes permitidos para CORS"
  type        = string
  default     = "*"
}

variable "cors_allow_credentials" {
  description = "Indica si se permiten credenciales en CORS"
  type        = bool
  default     = true
}

variable "enable_access_logs" {
  description = "Habilitar logs de acceso en CloudWatch"
  type        = bool
  default     = false
}

variable "manage_api_gateway_account" {
  description = "Si es true, configura el rol global de CloudWatch para la cuenta en esta región. Solo debe activarse en un microservicio o stack base."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
  default     = 7
}

variable "access_log_format" {
  description = "Formato de los logs de acceso en JSON"
  type        = string
  default     = "{ \"requestId\":\"$context.requestId\", \"ip\":\"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
}

variable "throttling_burst_limit" {
  description = "Límite de ráfaga de peticiones"
  type        = number
  default     = 1000
}

variable "throttling_rate_limit" {
  description = "Límite de tasa de peticiones por segundo"
  type        = number
  default     = 500
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
