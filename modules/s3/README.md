# S3 Module

Generic module to manage secure AWS S3 buckets with versioning, encryption, and lifecycle policies.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `bucket_name` | Name of the S3 bucket | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `enable_versioning` | Enable bucket versioning | `boolean` | No | `true` |
| `force_destroy` | Allow bucket deletion even if not empty | `boolean` | No | `false` |
| `allowed_origins` | List of allowed CORS origins | `list(string)` | No | `[]` |
| `kms_key_arn` | ARN of the KMS key for encryption | `string` | No | `null` |
| `transition_to_ia_days` | Days before transitioning to Infrequent Access | `number` | No | `null` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `bucket_id` | S3 bucket Name/ID |
| `bucket_arn` | S3 bucket ARN |
| `bucket_domain_name` | S3 bucket regional domain name |

## 📝 Usage Example

```hcl
module "storage" {
  source = "../../modules/s3"

  bucket_name = "rempays-assets"
  environment = "production"
  allowed_origins = ["https://rempays.com"]
}
```
