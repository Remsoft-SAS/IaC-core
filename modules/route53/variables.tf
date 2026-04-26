# modules/route53/variables.tf

variable "domain_name" {
  description = "Nombre del dominio"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "create_zone" {
  description = "Indica si se debe crear una nueva zona hospedada"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "ID de la zona hospedada (si create_zone es false)"
  type        = string
  default     = null
}

variable "records" {
  description = "Lista de registros a crear"
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), null)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }), null)
  }))
  default = []
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
