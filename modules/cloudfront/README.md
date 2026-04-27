# CloudFront Module

Manages AWS CloudFront Distributions with S3 origin support and OAC (Origin Access Control) security.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `comment` | Descriptive comment for the distribution | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `s3_bucket_domain_name` | Regional domain name of the S3 bucket | `string` | **Yes** | - |
| `default_root_object` | Default root object (e.g., `index.html`) | `string` | No | `"index.html"` |
| `price_class` | Price class (PriceClass_100, PriceClass_200, PriceClass_All) | `string` | No | `"PriceClass_100"` |
| `aliases` | List of custom domain names (CNAMEs) | `list(string)` | No | `[]` |
| `certificate_arn` | ARN of the ACM certificate (must be in `us-east-1`) | `string` | No | `null` |
| `certificate_domain` | Domain name to lookup the ACM certificate automatically | `string` | No | `null` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `distribution_id` | CloudFront distribution ID |
| `distribution_domain_name` | CloudFront distribution domain name |
| `distribution_arn` | CloudFront distribution ARN |

## 📝 Usage Example (Auto-Discovery)

```hcl
module "cdn" {
  source = "../../modules/cloudfront"

  comment               = "Rempays Landing"
  environment           = "production"
  s3_bucket_domain_name = "my-bucket.s3.us-east-1.amazonaws.com"
  aliases               = ["www.rempays.com"]
  certificate_domain    = "rempays.com" # Auto-lookup ARN
}
```
