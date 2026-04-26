# modules/sqs/variables.tf

variable "queue_name" {
  description = "Base name of the SQS queue"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "delay_seconds" {
  description = "Delay time in seconds for message delivery"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "Message retention time in seconds"
  type        = number
  default     = 345600 # 4 days
}

variable "receive_wait_time_seconds" {
  description = "Wait time for receiving messages (Long Polling)"
  type        = number
  default     = 10
}

variable "visibility_timeout_seconds" {
  description = "Message visibility timeout in seconds"
  type        = number
  default     = 30
}

variable "fifo_queue" {
  description = "Indicates if the queue is FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (FIFO only)"
  type        = bool
  default     = false
}

variable "high_throughput" {
  description = "Enable high throughput for FIFO queues"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "ID or ARN of the KMS key for encryption"
  type        = string
  default     = "alias/aws/sqs"
}

variable "enable_dlq" {
  description = "Enable Dead Letter Queue"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Maximum number of times a message is received before being moved to DLQ"
  type        = number
  default     = 5
}

variable "dlq_message_retention_seconds" {
  description = "Message retention time in DLQ in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "queue_policy" {
  description = "Queue access policy in JSON format (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
