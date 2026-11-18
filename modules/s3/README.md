# S3 bucket

Creates a private bucket with encryption, versioning, lifecycle cleanup, optional CORS, and CloudFront access policies.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/s3?ref=main"

  bucket_name = "replace-with-your-globally-unique-bucket"
  environment = "develop"
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/s3"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- The bucket name is used verbatim and must be globally unique. environment is used for tags, not appended to the name.
- Public access is always blocked. enable_website_hosting configures a website endpoint but does not make it publicly readable. For CloudFront use bucket_regional_domain_name with OAC.
- For CloudFront access set enable_oac_policy = true AND cloudfront_distribution_arn. Supplying only the ARN does not create a bucket policy unless bucket_policy is also set. The generated statement permits GetObject only from that distribution.
- Encryption defaults to AES256; provide kms_key_arn for SSE-KMS. KMS key policies and grants, including CloudFront decrypt access, must be managed separately.
- Versioning is enabled by default, incomplete multipart uploads are aborted after seven days, and noncurrent versions expire after 90 days by default. Optional transitions must comply with S3 storage-class minimum durations and object-size rules.
- force_destroy defaults to false. A nonempty bucket can block destroy; enabling force_destroy permits object deletion. CORS allows GET, PUT, POST, DELETE, and HEAD for the configured origins, but does not grant object access.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_s3_bucket.this`
- `aws_s3_bucket_versioning.this`
- `aws_s3_bucket_server_side_encryption_configuration.this`
- `aws_s3_bucket_public_access_block.this`
- `aws_s3_bucket_website_configuration.this`
- `aws_s3_bucket_cors_configuration.this`
- `aws_s3_bucket_lifecycle_configuration.this`
- `aws_s3_bucket_policy.this`

Data sources: `aws_iam_policy_document.combined`.

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `bucket_name` | Unique name of the S3 bucket | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `force_destroy` | Whether the bucket can be deleted even if it contains objects | `bool` | `false` | No |
| `enable_versioning` | Enable object versioning | `bool` | `true` | No |
| `enable_website_hosting` | Enable static website hosting | `bool` | `false` | No |
| `index_document` | Main page for website hosting | `string` | `"index.html"` | No |
| `kms_key_arn` | ARN of the KMS key for encryption (defaults to AES256 if null) | `string` | `null` | No |
| `allowed_origins` | List of allowed origins for CORS | `list(string)` | `[]` | No |
| `cloudfront_distribution_arn` | CloudFront Distribution ARN for the OAC bucket policy | `string` | `null` | No |
| `enable_oac_policy` | Set to true when cloudfront_distribution_arn is a computed value (e.g. from another module). Decouples the resource count from the computed ARN to avoid Terraform plan errors. | `bool` | `false` | No |
| `transition_to_ia_days` | Days before moving objects to Standard IA | `number` | `null` | No |
| `transition_to_glacier_days` | Days before moving objects to Glacier | `number` | `null` | No |
| `old_version_expiration_days` | Days before deleting old versions | `number` | `90` | No |
| `bucket_policy` | Additional bucket policy in JSON format (optional) | `string` | `null` | No |
| `tags` | Additional tags for the resource | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `bucket_id` | S3 bucket name (ID) |
| `bucket_arn` | S3 bucket ARN |
| `bucket_regional_domain_name` | Regional domain name of the bucket — use this for CloudFront S3 origins |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
