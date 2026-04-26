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
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "The billing_mode must be PROVISIONED or PAY_PER_REQUEST."
  }
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

variable "attributes" {
  description = "List of table attributes (name and type)"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "Global Secondary Indexes configuration"
  type        = any
  default     = []
}

variable "local_secondary_indexes" {
  description = "Local Secondary Indexes configuration"
  type        = any
  default     = []
}

variable "ttl_attribute" {
  description = "Attribute name for TTL (optional)"
  type        = string
  default     = null
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption (optional)"
  type        = string
  default     = null
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "replica_regions" {
  description = "Additional regions for global replication"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
