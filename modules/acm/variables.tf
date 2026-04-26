# modules/acm/variables.tf

variable "domain_name" {
  description = "Main domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of additional domains (SANs)"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "zone_id" {
  description = "Route 53 zone ID for DNS validation"
  type        = string
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
