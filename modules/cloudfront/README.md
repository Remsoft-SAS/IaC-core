# 🌐 AWS CloudFront Distribution Module (Advanced Edition)

High-performance Terraform module to manage AWS CloudFront distributions with support for **Hybrid Origins** (S3 for frontend + API Gateway for backend), automatic SSL integration, and SPA optimizations.

## 🌟 Key Features
- **Hybrid Routing:** Seamlessly route traffic between S3 (static assets) and API Gateway (dynamic API) using a single distribution.
- **SPA Optimized:** Built-in support for Single Page Applications with automatic 404/403 redirection to `index.html`.
- **Smart URL Rewriting:** Includes a CloudFront Function to handle subfolder `index.html` resolution (important for Next.js/Vite exports).
- **Security Headers:** Automatic implementation of industry-standard security headers (HSTS, XSS Protection, Frame Options).
- **Zero-Touch SSL:** Automatically looks up the ACM certificate in `us-east-1` based on the provided domain.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `comment` | Description for the distribution. | `string` | - | **Yes** |
| `environment` | develop/production. | `string` | - | **Yes** |
| `s3_bucket_domain_name` | S3 Origin Domain. | `string` | - | **Yes** |
| `api_gateway_domain_name` | API Origin Domain. [See Hybrid Routing](#-hybrid-routing-setup) | `string` | `null` | No |
| `certificate_domain` | Domain for SSL lookup (us-east-1). | `string` | `null` | No |
| `is_spa` | Enable SPA error handling. | `bool` | `true` | No |
| `price_class` | CloudFront price class. | `string` | `PriceClass_100` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `distribution_id` | The ID of the CloudFront distribution. |
| `domain_name` | The CloudFront default domain name (e.g., d123.cloudfront.net). |
| `arn` | The ARN of the distribution. |

---

## 🧠 Hybrid Routing Setup

This module allows you to serve a frontend and a backend from the same domain.

| Traffic Path | Target Origin | Cache Policy |
| :--- | :--- | :--- |
| `/*` (Default) | S3 Bucket | Optimized for static assets |
| `/api/*` (Custom) | API Gateway | Bypasses cache, forwards headers/cookies |

### Example Configuration
```hcl
module "cdn" {
  source = "..."
  comment = "My App"
  
  s3_bucket_domain_name   = module.s3.bucket_regional_domain_name
  api_gateway_domain_name = replace(module.api.api_url, "https://", "") # Remove protocol
  
  aliases = ["myapp.com"]
  certificate_domain = "myapp.com"
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
