# AWS CloudFront Distribution Module

Terraform module to manage CloudFront distributions with support for S3 static origins, optional API Gateway backend routing, automatic SSL, SPA support, and Route53 DNS management.

## Key Features
- **S3 Origin with OAC:** Secure private S3 origin using Origin Access Control.
- **Hybrid Routing:** Optional API Gateway origin routed via a path pattern (e.g. `/api/*`).
- **SPA Support:** Redirects 403/404 to `index.html` for single-page applications.
- **URL Rewriting:** CloudFront Function to resolve subfolder `index.html` (Next.js / Vite exports).
- **Security Headers:** HSTS, XSS protection, frame options, referrer policy applied automatically.
- **Zero-Touch SSL:** Looks up the ACM certificate in `us-east-1` from the provided domain.
- **Route53 DNS:** Creates an A alias record automatically when `route53_zone_id` is provided.

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `comment` | Description for the distribution | `string` | — | **Yes** |
| `environment` | Target environment (`develop`/`production`) | `string` | — | **Yes** |
| `s3_bucket_domain_name` | Regional domain name of the S3 origin bucket | `string` | — | **Yes** |
| `aliases` | Custom domain names (CNAMEs) | `list(string)` | `[]` | No |
| `certificate_domain` | Domain for ACM certificate lookup in `us-east-1` | `string` | `null` | No |
| `route53_zone_id` | Route53 Hosted Zone ID — creates an A alias for `aliases[0]` when provided | `string` | `null` | No |
| `api_gateway_domain_name` | API Gateway domain for hybrid routing (without protocol) | `string` | `null` | No |
| `api_path_pattern` | Path pattern routed to API Gateway | `string` | `/api/*` | No |
| `is_spa` | Enable SPA mode (403/404 → index.html) | `bool` | `true` | No |
| `enable_url_rewrite` | Enable CloudFront Function for subfolder URL rewriting | `bool` | `true` | No |
| `default_root_object` | Default root object | `string` | `index.html` | No |
| `price_class` | CloudFront price class | `string` | `PriceClass_100` | No |
| `web_acl_id` | WAF Web ACL ID | `string` | `null` | No |
| `tags` | Additional resource tags | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| :--- | :--- |
| `distribution_id` | CloudFront distribution ID |
| `distribution_domain_name` | Default CloudFront domain (e.g. `d123.cloudfront.net`) |
| `distribution_hosted_zone_id` | Hosted zone ID of the distribution (for Route53 alias records) |
| `distribution_arn` | Distribution ARN |
| `oac_id` | Origin Access Control ID |

## Usage

### Assets CDN with Route53

```hcl
module "cdn_assets" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cloudfront?ref=main"

  comment     = "CDN for Assets"
  environment = var.environment

  s3_bucket_domain_name = module.s3_assets.bucket_regional_domain_name

  aliases            = ["cdn.rempays.online"]
  certificate_domain = "rempays.online"
  route53_zone_id    = data.aws_route53_zone.selected.zone_id

  is_spa             = false
  enable_url_rewrite = false
}
```

### App with Hybrid Routing (Frontend + API)

```hcl
module "cdn" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cloudfront?ref=main"

  comment     = "My App CDN"
  environment = var.environment

  s3_bucket_domain_name   = module.s3.bucket_regional_domain_name
  api_gateway_domain_name = replace(module.api.api_url, "https://", "")

  aliases            = ["app.rempays.online"]
  certificate_domain = "rempays.online"
  route53_zone_id    = data.aws_route53_zone.selected.zone_id

  is_spa             = true
  enable_url_rewrite = true
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
