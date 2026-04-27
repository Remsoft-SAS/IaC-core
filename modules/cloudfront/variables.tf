# modules/cloudfront/variables.tf

variable "comment" {
  description = "Descriptive comment for the distribution"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "List of custom domain names (CNAMEs)"
  type        = list(string)
  default     = []
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate (must be in us-east-1)"
  type        = string
  default     = null
}

variable "certificate_domain" {
  description = "Domain name to lookup the ACM certificate automatically"
  type        = string
  default     = null
}

variable "is_spa" {
  description = "Enable SPA mode (redirects 403/404 to index.html)"
  type        = bool
  default     = true
}

variable "enable_url_rewrite" {
  description = "Enable CloudFront Function for URL rewriting (appends index.html to subfolders)"
  type        = bool
  default     = true
}

variable "web_acl_id" {
  description = "Optional WAF Web ACL ID to associate with the distribution"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
