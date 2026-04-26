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
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `distribution_id` | CloudFront distribution ID |
| `distribution_domain_name` | CloudFront distribution domain name |
| `distribution_arn` | CloudFront distribution ARN |

## 📝 Usage Example

```hcl
module "cdn" {
  source = "../../modules/cloudfront"

  comment               = "Rempays Landing"
  environment           = "production"
  s3_bucket_domain_name = module.s3_bucket.bucket_regional_domain_name
  aliases               = ["www.rempays.com"]
  certificate_arn       = "arn:aws:acm:us-east-1:..."
}
```
