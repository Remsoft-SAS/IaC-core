# AWS S3 Advanced Storage Module

Enterprise-grade Terraform module to manage Amazon S3 buckets with built-in OAC policy management, lifecycle cost optimization, and optional static website hosting.

## Key Features
- **OAC Integration:** Automatically creates a bucket policy for CloudFront OAC when `cloudfront_distribution_arn` is provided.
- **Lifecycle Rules:** Multi-tier support for Standard-IA and Glacier transitions plus automatic old-version cleanup.
- **Security-First:** Public access block enabled by default, server-side encryption (AES256 or KMS), versioning.
- **Website Hosting:** Optional static website endpoint.
- **Multipart Cleanup:** Automatically aborts incomplete uploads after 7 days.

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `bucket_name` | Globally unique name for the bucket | `string` | — | **Yes** |
| `environment` | Target environment (`develop`/`production`) | `string` | — | **Yes** |
| `cloudfront_distribution_arn` | CloudFront Distribution ARN for OAC bucket policy | `string` | `null` | No |
| `enable_oac_policy` | Set `true` when `cloudfront_distribution_arn` is a computed value to avoid Terraform plan errors | `bool` | `false` | No |
| `enable_versioning` | Enable object versioning | `bool` | `true` | No |
| `enable_website_hosting` | Enable static website hosting | `bool` | `false` | No |
| `transition_to_ia_days` | Days before transitioning objects to Standard-IA | `number` | `null` | No |
| `transition_to_glacier_days` | Days before transitioning objects to Glacier | `number` | `null` | No |
| `old_version_expiration_days` | Days before deleting non-current versions | `number` | `90` | No |
| `allowed_origins` | CORS allowed origins | `list(string)` | `[]` | No |
| `kms_key_arn` | KMS key ARN for encryption (defaults to AES256 if null) | `string` | `null` | No |
| `bucket_policy` | Additional bucket policy JSON (merged with OAC policy) | `string` | `null` | No |
| `force_destroy` | Allow bucket deletion even if it contains objects | `bool` | `false` | No |
| `tags` | Additional resource tags | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| :--- | :--- |
| `bucket_id` | Bucket name (ID) |
| `bucket_arn` | Bucket ARN |
| `bucket_regional_domain_name` | Regional domain name — use as `s3_bucket_domain_name` for CloudFront origins |

## OAC Setup

Pass `cloudfront_distribution_arn` and `enable_oac_policy = true` together. The boolean controls the resource `count` (known at plan time), while the ARN is used in the policy document (resolved at apply time).

```hcl
module "s3_assets" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/s3?ref=main"
  bucket_name = "my-app-assets"
  environment = var.environment

  cloudfront_distribution_arn = module.cdn.distribution_arn
  enable_oac_policy           = true
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
