# modules/step_functions/variables.tf

variable "name" {
  description = "Nombre base de la State Machine (se agrega -{environment})"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (develop / production)"
  type        = string
}

variable "definition" {
  description = "Definicion ASL de la State Machine (JSON string)"
  type        = string
}

variable "type" {
  description = "Tipo de State Machine: STANDARD o EXPRESS"
  type        = string
  default     = "EXPRESS"
}

variable "lambda_arns" {
  description = "Lista de ARNs de Lambdas que la State Machine puede invocar"
  type        = list(string)
  default     = []
}

variable "log_level" {
  description = "Nivel de logging: ALL | ERROR | FATAL | OFF"
  type        = string
  default     = "ERROR"
}

variable "log_include_execution_data" {
  description = "Incluir input/output de cada estado en los logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Dias de retencion del CloudWatch Log Group"
  type        = number
  default     = 14
}

variable "eventbridge_trigger" {
  description = "Configuracion del trigger EventBridge (null = sin trigger)"
  type = object({
    bus_name      = string
    event_pattern = string
  })
  default = null
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
