# modules/sns/variables.tf

variable "topic_name" {
  description = "Base name of the SNS topic"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "display_name" {
  description = "Display name for the SNS topic (used for SMS)"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Whether the topic should be FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (FIFO only)"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
  default     = "alias/aws/sns"
}

variable "allowed_publishers" {
  description = "List of ARNs or Service Principals allowed to publish to this topic (e.g. ['s3.amazonaws.com', 'arn:aws:iam::...'])"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
