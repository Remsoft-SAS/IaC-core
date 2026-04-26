# modules/dynamodb/variables.tf

variable "table_name" {
  description = "Nombre base de la tabla DynamoDB"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "billing_mode" {
  description = "Modo de facturación: PROVISIONED o PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "El billing_mode debe ser PROVISIONED o PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "Nombre del atributo usado como Hash Key"
  type        = string
}

variable "range_key" {
  description = "Nombre del atributo usado como Range Key (opcional)"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "Capacidad de lectura (solo si billing_mode es PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Capacidad de escritura (solo si billing_mode es PROVISIONED)"
  type        = number
  default     = 5
}

variable "attributes" {
  description = "Lista de atributos de la tabla (name y type)"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "Configuración de Global Secondary Indexes"
  type        = any
  default     = []
}

variable "local_secondary_indexes" {
  description = "Configuración de Local Secondary Indexes"
  type        = any
  default     = []
}

variable "ttl_attribute" {
  description = "Nombre del atributo para TTL (opcional)"
  type        = string
  default     = null
}

variable "enable_point_in_time_recovery" {
  description = "Habilitar recuperación en un punto en el tiempo"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Habilitar encriptación server-side"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para encriptación (opcional)"
  type        = string
  default     = null
}

variable "enable_streams" {
  description = "Habilitar DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Tipo de vista del stream (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "replica_regions" {
  description = "Regiones adicionales para replicación global"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
