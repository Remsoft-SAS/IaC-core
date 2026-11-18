# Lambda layer

Publishes a Lambda layer version from a ZIP file or S3 object, with optional cross-account permissions.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda_layer?ref=main"

  layer_name          = "example-dependencies"
  environment         = "develop"
  filename            = "${path.module}/layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/layer.zip")
  compatible_runtimes = ["nodejs22.x"]
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/lambda_layer"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Build the ZIP before planning, with the runtime layout required by Lambda (for example nodejs/node_modules or python/). No packaging or dependency installation is performed.
- Provide filename or s3_bucket plus s3_key, not both. For local ZIPs pass source_code_hash to detect content changes; for S3 use immutable keys or object versions.
- Names append -environment. Updating code publishes a new version; consumers must update their versioned layer ARN. skip_destroy retains superseded versions and leaves cleanup to you.
- Each layer_permissions statement_id must be unique. principal is an account ID or *, with optional organization_id. Scope public and organization access deliberately.
- compatible_architectures accepts x86_64 and arm64. tags is declared but unused; Lambda layer versions are not tagged by this module. license_info describes your layer contents and is unrelated to this repository license.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_lambda_layer_version.this`
- `aws_lambda_layer_version_permission.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `layer_name` | Unique name for the Lambda Layer | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `filename` | Path to the local .zip file containing the layer code. Conflicts with s3_bucket/s3_key. | `string` | `null` | No |
| `source_code_hash` | Base64-encoded SHA256 hash of the zip. Used to detect changes when using filename. Tipically: filebase64sha256(var.filename) | `string` | `null` | No |
| `s3_bucket` | S3 bucket where the layer zip is stored. Conflicts with filename. | `string` | `null` | No |
| `s3_key` | S3 object key of the layer zip. Required when s3_bucket is set. | `string` | `null` | No |
| `s3_object_version` | S3 object version of the layer zip. Optional, use when bucket versioning is enabled. | `string` | `null` | No |
| `compatible_runtimes` | List of Lambda runtimes compatible with this layer (up to 15). E.g. ["python3.12", "python3.11"] | `list(string)` | `[]` | No |
| `compatible_architectures` | List of CPU architectures compatible with this layer. Valid values: x86_64, arm64. | `list(string)` | `["x86_64"]` | No |
| `description` | Human-readable description of the layer | `string` | `""` | No |
| `license_info` | SPDX license identifier for the layer (e.g. MIT, Apache-2.0) | `string` | `null` | No |
| `skip_destroy` | When true, old layer versions are retained in AWS when a new version is published. Useful to avoid breaking live functions during deployments. | `bool` | `false` | No |
| `layer_permissions` | List of cross-account (or organization) permissions to grant GetLayerVersion on this layer. | `See schema below` | `[]` | No |
| `tags` | Unused input; no tags are applied. | `map(string)` | `{}` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `layer_permissions`

```hcl
list(object({
    statement_id    = string
    principal       = string
    organization_id = optional(string, null)
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `arn` | Full ARN of the Lambda Layer version (includes version number) — use this in aws_lambda_function.layers |
| `layer_arn` | ARN of the Lambda Layer without version number |
| `layer_name` | Name of the Lambda Layer as created in AWS |
| `version` | Published version number of the layer |
| `created_date` | Date the layer version was created |
| `source_code_size` | Size of the layer zip in bytes |
| `compatible_runtimes` | Runtimes compatible with this layer version |
| `compatible_architectures` | CPU architectures compatible with this layer version |
| `signing_job_arn` | ARN of the signing job (only present if the layer was signed) |
| `signing_profile_version_arn` | ARN of the signing profile version (only present if the layer was signed) |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
