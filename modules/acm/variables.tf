# modules/acm/variables.tf

variable "domain_name" {
  description = "Nombre de dominio principal para el certificado"
  type        = string
}

variable "subject_alternative_names" {
  description = "Lista de dominios adicionales (SANs)"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "zone_id" {
  description = "ID de la zona de Route 53 para validación DNS"
  type        = string
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
