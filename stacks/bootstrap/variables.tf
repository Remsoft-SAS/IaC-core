# stacks/bootstrap/variables.tf

variable "project_name" {
  description = "Nombre del proyecto (ej: rempays)"
  type        = string
  default     = "rempays"
}

variable "environment" {
  description = "Entorno (ej: production, shared)"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
