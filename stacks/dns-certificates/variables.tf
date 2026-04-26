# stacks/dns-certificates/variables.tf

variable "domain_name" {
  description = "Main domain name (e.g., rempays.online or rempays.com)"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
