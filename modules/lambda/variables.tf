# modules/lambda/variables.tf

variable "function_name" {
  description = "Base name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "handler" {
  description = "Function handler (e.g., index.handler)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Execution runtime (e.g., nodejs22.x)"
  type        = string
  default     = "nodejs22.x"
}

variable "memory_size" {
  description = "Allocated memory in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Maximum execution time in seconds"
  type        = number
  default     = 30
}

variable "filename" {
  description = "Path to local .zip file (for local deployments)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket where the code is located"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key for the code"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version"
  type        = string
  default     = null
}

variable "vpc_config" {
  description = "VPC configuration (subnet_ids and security_group_ids)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

variable "inline_policies" {
  description = "List of additional inline policies {name, policy}"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

# --- Event Trigger (Smart Mapping) ---
variable "event_source_arn" {
  description = "ARN of the event source (SQS, DynamoDB Stream, etc.)"
  type        = string
  default     = null
}

variable "event_source_batch_size" {
  description = "The largest number of records that Lambda will retrieve from your event source at the time of invoking your function"
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "Log retention days in CloudWatch"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
