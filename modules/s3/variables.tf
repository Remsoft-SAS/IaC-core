# modules/s3/variables.tf

variable "bucket_name" {
  description = "Nombre único del bucket S3"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "force_destroy" {
  description = "Indica si se puede borrar el bucket aunque contenga objetos"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Habilitar versionamiento de objetos"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para encriptación (si es null se usa AES256)"
  type        = string
  default     = null
}

variable "allowed_origins" {
  description = "Lista de orígenes permitidos para CORS"
  type        = list(string)
  default     = []
}

variable "old_version_expiration_days" {
  description = "Días antes de borrar versiones antiguas (solo si versioning está habilitado)"
  type        = number
  default     = 30
}

variable "transition_to_ia_days" {
  description = "Días antes de mover objetos a Standard IA (opcional)"
  type        = number
  default     = null
}

variable "bucket_policy" {
  description = "Política del bucket en formato JSON (opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
