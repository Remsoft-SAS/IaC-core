# modules/lambda_layer/variables.tf

# --- Required ---
variable "layer_name" {
  description = "Unique name for the Lambda Layer"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

# --- Source: local file or S3 (one of the two must be provided) ---
variable "filename" {
  description = "Path to the local .zip file containing the layer code. Conflicts with s3_bucket/s3_key."
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the zip. Used to detect changes when using filename. Tipically: filebase64sha256(var.filename)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket where the layer zip is stored. Conflicts with filename."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 object key of the layer zip. Required when s3_bucket is set."
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the layer zip. Optional, use when bucket versioning is enabled."
  type        = string
  default     = null
}

# --- Runtime & Architecture ---
variable "compatible_runtimes" {
  description = "List of Lambda runtimes compatible with this layer (up to 15). E.g. [\"python3.12\", \"python3.11\"]"
  type        = list(string)
  default     = []
}

variable "compatible_architectures" {
  description = "List of CPU architectures compatible with this layer. Valid values: x86_64, arm64."
  type        = list(string)
  default     = ["x86_64"]

  validation {
    condition     = alltrue([for a in var.compatible_architectures : contains(["x86_64", "arm64"], a)])
    error_message = "compatible_architectures must be one or more of: x86_64, arm64."
  }
}

# --- Metadata ---
variable "description" {
  description = "Human-readable description of the layer"
  type        = string
  default     = ""
}

variable "license_info" {
  description = "SPDX license identifier for the layer (e.g. MIT, Apache-2.0)"
  type        = string
  default     = null
}

# --- Lifecycle ---
variable "skip_destroy" {
  description = "When true, old layer versions are retained in AWS when a new version is published. Useful to avoid breaking live functions during deployments."
  type        = bool
  default     = false
}

# --- Cross-account permissions ---
variable "layer_permissions" {
  description = "List of cross-account (or organization) permissions to grant GetLayerVersion on this layer."
  type = list(object({
    statement_id    = string                 # Unique ID for the permission statement
    principal       = string                 # AWS account ID or "*" for all accounts
    organization_id = optional(string, null) # AWS Organization ID (e.g. o-xxxxxxxx) — restricts to org members
  }))
  default = []
}

# --- Tags ---
variable "tags" {
  description = "Additional tags for the layer resource"
  type        = map(string)
  default     = {}
}
