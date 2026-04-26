# ACM Module (AWS Certificate Manager)

Manages SSL/TLS certificates with automated DNS validation via Route 53.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `domain_name` | Main domain name for the certificate | `string` | **Yes** | - |
| `zone_id` | Route 53 zone ID for DNS validation | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `subject_alternative_names` | List of additional domains (SANs) | `list(string)` | No | `[]` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `certificate_arn` | ARN of the validated certificate |
| `certificate_domain` | Primary domain of the certificate |

## 📝 Usage Example

```hcl
module "acm" {
  source = "../../modules/acm"

  domain_name = "example.com"
  zone_id     = "Z1234567890"
  environment = "production"
}
```
