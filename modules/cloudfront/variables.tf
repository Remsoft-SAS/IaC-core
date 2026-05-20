# modules/cloudfront/variables.tf

variable "comment" {
  description = "Descriptive comment for the distribution"
  type        = string
}

variable "environment" {
  description = "Target environment (develop/production)"
  type        = string
}

# --- S3 Origin (Static Assets) ---
variable "s3_bucket_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

# --- API Gateway Origin (Backend API) ---
variable "api_gateway_domain_name" {
  description = "Domain name of the API Gateway (without protocol)"
  type        = string
  default     = null
}

variable "api_path_pattern" {
  description = "Path pattern to redirect to API Gateway (e.g. /api/*)"
  type        = string
  default     = "/api/*"
}

# --- Common Config ---
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

variable "certificate_domain" {
  description = "Domain name to lookup the ACM certificate automatically (must be in us-east-1)"
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

# --- Security ---
variable "enable_waf" {
  description = "Enable a basic AWS WAF with Core Rule Set"
  type        = bool
  default     = false
}

variable "web_acl_id" {
  description = "Optional custom WAF Web ACL ID (overrides enable_waf)"
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID to create an A alias record for the first alias domain. Leave null to skip."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for the resource"
  type        = map(string)
  default     = {}
}
