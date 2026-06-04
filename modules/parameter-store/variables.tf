# modules/parameter-store/variables.tf

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "parameters" {
  description = "List of parameters to create in Parameter Store"
  type = list(object({
    name                = string
    value               = string
    type                = string
    description         = optional(string, "Managed by Terraform")
    key_id              = optional(string, null)
    tier                = optional(string, "Standard")
    data_type           = optional(string, "text")
    ignore_value_changes = optional(bool, false)
    tags                = optional(map(string), {})
  }))
}
