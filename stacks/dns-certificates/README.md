# DNS & Certificates Stack

Manages the public domain presence and SSL security for a project.

---

## 🛠️ Resources Created

1.  **Route53 Public Hosted Zone**: The primary DNS zone for the project.
2.  **ACM Certificate**: A global wildcard certificate (`*.domain.com`).
3.  **DNS Validation**: Automated records in Route53 to validate SSL ownership.

## 📥 Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| `domain_name` | The base domain (e.g., `rempays.com`) | `string` | **Yes** |
| `environment` | `develop` or `production` | `string` | **Yes** |
| `aws_region` | AWS Region (Certificates are usually created in `us-east-1` for CloudFront) | `string` | No |

## 📝 Usage Example

```hcl
module "dns" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//stacks/dns-certificates?ref=main"

  domain_name = "rempays.com"
  environment = var.environment
}
```

## 📤 Outputs

- `zone_id`: The ID of the created Route53 zone.
- `certificate_arn`: The ARN of the validated SSL certificate.
