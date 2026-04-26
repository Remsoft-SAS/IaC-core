# modules/parameter-store/variables.tf

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "parameters" {
  description = "Lista de parámetros a crear en Parameter Store"
  type = list(object({
    name        = string
    value       = string
    type        = string
    description = optional(string, "Managed by Terraform")
    key_id      = optional(string, null)
    overwrite   = optional(bool, true)
    tier        = optional(string, "Standard")
    tags        = optional(map(string), {})
  }))
}
