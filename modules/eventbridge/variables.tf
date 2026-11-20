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

variable "existing_bus_name" {
  description = "Name of the existing event bus used for attaching rules when create is false."
  type        = string
  default     = "default"
}

variable "rules" {
  description = "EventBridge rules and targets. Supply event_pattern for event matching, schedule_expression for cron/rate schedules, or both."
  type = map(object({
    description         = optional(string, "")
    event_pattern       = optional(string)
    schedule_expression = optional(string)
    enabled             = optional(bool, true)
    targets = optional(map(object({
      arn      = string
      role_arn = optional(string)
      input    = optional(string)
    })), {})
  }))
  default = {}
}

variable "schedules" {
  description = "EventBridge Scheduler schedules. Target IAM roles and target permissions are supplied and managed by the caller."
  type = map(object({
    description                  = optional(string, "")
    schedule_expression          = string
    schedule_expression_timezone = optional(string, "UTC")
    state                        = optional(string, "ENABLED")
    start_date                   = optional(string)
    end_date                     = optional(string)
    flexible_time_window_mode    = optional(string, "OFF")
    flexible_time_window_minutes = optional(number)
    target_arn                   = string
    target_role_arn              = string
    target_input                 = optional(string)
    retry_maximum_event_age      = optional(number)
    retry_maximum_attempts       = optional(number)
    dead_letter_arn              = optional(string)
    group_name                   = optional(string, "default")
  }))
  default = {}
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
