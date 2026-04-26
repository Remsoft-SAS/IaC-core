# modules/route53/variables.tf

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "create_zone" {
  description = "Indicates whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Hosted zone ID (if create_zone is false)"
  type        = string
  default     = null
}

variable "records" {
  description = "List of records to create"
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
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
