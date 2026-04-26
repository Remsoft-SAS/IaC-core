# modules/lambda/variables.tf

variable "function_name" {
  description = "Nombre base de la función Lambda"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "handler" {
  description = "Handler de la función (ej: index.handler)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime de la función (ej: nodejs18.x)"
  type        = string
  default     = "nodejs18.x"
}

variable "memory_size" {
  description = "Memoria asignada a la función en MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Tiempo máximo de ejecución en segundos"
  type        = number
  default     = 30
}

variable "filename" {
  description = "Ruta al archivo .zip local (si se usa despliegue local)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "Bucket S3 donde se encuentra el código"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "Llave S3 del código"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Versión del objeto S3"
  type        = string
  default     = null
}

variable "vpc_config" {
  description = "Configuración de VPC (subnet_ids y security_group_ids)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "environment_variables" {
  description = "Variables de entorno para la función"
  type        = map(string)
  default     = {}
}

variable "inline_policies" {
  description = "Lista de políticas inline adicionales {name, policy}"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
