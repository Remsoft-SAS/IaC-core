# modules/s3/variables.tf

variable "bucket_name" {
  description = "Unique name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "force_destroy" {
  description = "Indicates whether the bucket can be deleted even if it contains objects"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable object versioning"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption (defaults to AES256 if null)"
  type        = string
  default     = null
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "old_version_expiration_days" {
  description = "Days before deleting old versions (only if versioning is enabled)"
  type        = number
  default     = 30
}

variable "transition_to_ia_days" {
  description = "Days before moving objects to Standard IA (optional)"
  type        = number
  default     = null
}

variable "bucket_policy" {
  description = "Bucket policy in JSON format (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
