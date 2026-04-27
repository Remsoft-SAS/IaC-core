# CloudFront Elite Module 🚀

Advanced AWS CloudFront module optimized for SPAs (React/Next), Multi-page sites, and security-first environments.

---

## 🔥 Elite Features
- **URL Auto-Rewrite:** Built-in CloudFront Function that appends `index.html` to subfolder requests (e.g., `/dashboard/` -> `/dashboard/index.html`).
- **SPA Mode:** Native support for 403/404 error redirection to `index.html`.
- **Security Headers:** Automatic implementation of HSTS, Frame Options, XSS Protection, and Referrer Policy.
- **Certificate Auto-Discovery:** Find ACM certificates by domain name automatically.
- **Modern Protocols:** Support for HTTP/2 and HTTP/3 by default.
- **WAF Integration:** Seamlessly attach a Web ACL.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `comment` | Descriptive comment for the distribution | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `s3_bucket_domain_name` | Regional domain name of the S3 bucket | `string` | **Yes** | - |
| `aliases` | List of custom domain names (CNAMEs) | `list(string)` | No | `[]` |
| `certificate_domain` | Domain name for auto-discovery of ACM certificate | `string` | No | `null` |
| `is_spa` | Enable SPA mode (redirects 403/404 to `/index.html`) | `bool` | No | `true` |
| `enable_url_rewrite` | Enable URL rewrite function for subfolders | `bool` | No | `true` |
| `web_acl_id` | Optional WAF Web ACL ID | `string` | No | `null` |
| `tags` | Additional tags | `map(string)` | No | `{}` |

---

## 📝 Usage Example (Ultra Clean)

```hcl
module "cdn" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cloudfront?ref=main"

  comment               = "Rempays Dashboard"
  environment           = "production"
  s3_bucket_domain_name = "my-bucket.s3.us-east-1.amazonaws.com"
  aliases               = ["app.rempays.com"]
  certificate_domain    = "rempays.com"
  
  # Advanced options (enabled by default)
  is_spa             = true
  enable_url_rewrite = true
}
```
