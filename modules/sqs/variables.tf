# modules/sqs/variables.tf

variable "queue_name" {
  description = "Nombre base de la cola SQS"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "delay_seconds" {
  description = "Tiempo de retraso en segundos para la entrega de mensajes"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Tamaño máximo del mensaje en bytes"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "Tiempo de retención del mensaje en segundos"
  type        = number
  default     = 345600 # 4 días
}

variable "receive_wait_time_seconds" {
  description = "Tiempo de espera para recibir mensajes (Long Polling)"
  type        = number
  default     = 10
}

variable "visibility_timeout_seconds" {
  description = "Tiempo de visibilidad del mensaje en segundos"
  type        = number
  default     = 30
}

variable "fifo_queue" {
  description = "Indica si la cola es FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Habilitar deduplicación basada en contenido (solo FIFO)"
  type        = bool
  default     = false
}

variable "high_throughput" {
  description = "Habilitar alto rendimiento para colas FIFO"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "ID o ARN de la llave KMS para encriptación"
  type        = string
  default     = "alias/aws/sqs"
}

variable "enable_dlq" {
  description = "Habilitar Dead Letter Queue"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Número máximo de veces que se recibe un mensaje antes de ir a DLQ"
  type        = number
  default     = 5
}

variable "dlq_message_retention_seconds" {
  description = "Tiempo de retención del mensaje en DLQ en segundos"
  type        = number
  default     = 1209600 # 14 días
}

variable "queue_policy" {
  description = "Política de acceso a la cola en formato JSON (opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
