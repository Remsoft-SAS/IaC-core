variable "name" {
  description = "Name of the Regional Web ACL and its CloudWatch metric"
  type        = string
}

variable "description" {
  description = "Description of the Web ACL"
  type        = string
  default     = "Regional IP rate limiting"
}

variable "rule_name" {
  description = "Name of the rate-based rule"
  type        = string
  default     = "rate-limit-by-source-ip"
}

variable "rate_limit_per_5m" {
  description = "Maximum requests per source IP during the evaluation window"
  type        = number
  default     = 10000

  validation {
    condition     = var.rate_limit_per_5m >= 100
    error_message = "AWS WAF rate-based rules require a limit of at least 100 requests."
  }
}

variable "evaluation_window_sec" {
  description = "Rolling rate evaluation window in seconds"
  type        = number
  default     = 300

  validation {
    condition     = contains([60, 300, 600, 1200], var.evaluation_window_sec)
    error_message = "Use an AWS WAF evaluation window of 60, 300, 600, or 1200 seconds."
  }
}

variable "resource_arns" {
  description = "Regional API Gateway REST stage ARNs to associate with this Web ACL"
  type        = list(string)
  default     = []
}

variable "metric_name" {
  description = "Optional CloudWatch metric name for the rate-based rule"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the Web ACL"
  type        = map(string)
  default     = {}
}
