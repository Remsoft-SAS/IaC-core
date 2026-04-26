# modules/cloudfront/variables.tf

variable "comment" {
  description = "Comentario descriptivo para la distribución"
  type        = string
}

variable "environment" {
  description = "Entorno (develop/production)"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "Nombre de dominio regional del bucket S3"
  type        = string
}

variable "default_root_object" {
  description = "Objeto raíz por defecto"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Clase de precio (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Lista de dominios personalizados (CNAMEs)"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "ARN del certificado ACM (debe estar en us-east-1)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionales para el recurso"
  type        = map(string)
  default     = {}
}
