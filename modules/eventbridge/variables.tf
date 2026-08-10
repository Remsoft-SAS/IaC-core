# modules/eventbridge/variables.tf

variable "bus_name" {
  description = "Nombre base del EventBridge custom bus"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (develop / production)"
  type        = string
}

variable "create" {
  description = "Si es false, no crea el bus — usa existing_bus_arn como referencia"
  type        = bool
  default     = true
}

variable "existing_bus_arn" {
  description = "ARN de un bus existente (solo si create = false)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
