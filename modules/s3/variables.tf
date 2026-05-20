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
  description = "Whether the bucket can be deleted even if it contains objects"
  type        = bool
  default     = false
}

# --- Features ---
variable "enable_versioning" {
  description = "Enable object versioning"
  type        = bool
  default     = true
}

variable "enable_website_hosting" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "index_document" {
  description = "Main page for website hosting"
  type        = string
  default     = "index.html"
}

# --- Security ---
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

variable "cloudfront_distribution_arn" {
  description = "CloudFront Distribution ARN for the OAC bucket policy"
  type        = string
  default     = null
}

variable "enable_oac_policy" {
  description = "Set to true when cloudfront_distribution_arn is a computed value (e.g. from another module). Decouples the resource count from the computed ARN to avoid Terraform plan errors."
  type        = bool
  default     = false
}


# --- Lifecycle Rules ---
variable "transition_to_ia_days" {
  description = "Days before moving objects to Standard IA"
  type        = number
  default     = null
}

variable "transition_to_glacier_days" {
  description = "Days before moving objects to Glacier"
  type        = number
  default     = null
}

variable "old_version_expiration_days" {
  description = "Days before deleting old versions"
  type        = number
  default     = 90
}

# --- Customization ---
variable "bucket_policy" {
  description = "Additional bucket policy in JSON format (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
