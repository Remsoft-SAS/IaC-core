# modules/dynamodb/variables.tf

variable "table_name" {
  description = "Base name of the DynamoDB table"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode: PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity (only if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity (only if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "hash_key" {
  description = "Attribute name used as Hash Key"
  type        = string
}

variable "range_key" {
  description = "Attribute name used as Range Key (optional)"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of table attributes (required for keys and indexes)"
  type = list(object({
    name = string
    type = string # S, N, or B
  }))
}

# --- Indexing ---

variable "global_secondary_indexes" {
  description = "Global Secondary Indexes configuration"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "Local Secondary Indexes configuration"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string # ALL, KEYS_ONLY, INCLUDE
    non_key_attributes = optional(list(string))
  }))
  default = []
}

# --- Advanced Features ---

variable "ttl_attribute" {
  description = "Attribute name for Time-To-Live (optional)"
  type        = string
  default     = null
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for disaster recovery"
  type        = bool
  default     = true
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams for event-driven flows"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream content: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
