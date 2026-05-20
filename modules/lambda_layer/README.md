# AWS Lambda Layer Module

Terraform module to create and version AWS Lambda Layers. Supports local zip files or S3 sources, multiple runtimes and architectures, and optional cross-account/organization permissions.

## Inputs

### Required

| Name | Description | Type |
| :--- | :--- | :--- |
| `layer_name` | Unique name for the Lambda Layer. | `string` |
| `environment` | Target environment (develop/production). | `string` |

### Source — local file or S3 (one required)

| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `filename` | Path to local `.zip` file. Conflicts with `s3_bucket`/`s3_key`. | `string` | `null` |
| `source_code_hash` | `filebase64sha256(var.filename)` — triggers layer update on file change. | `string` | `null` |
| `s3_bucket` | S3 bucket containing the layer zip. Conflicts with `filename`. | `string` | `null` |
| `s3_key` | S3 object key of the layer zip. | `string` | `null` |
| `s3_object_version` | S3 object version (when bucket versioning is enabled). | `string` | `null` |

### Runtime & Architecture

| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `compatible_runtimes` | Compatible Lambda runtimes (up to 15). E.g. `["python3.12", "nodejs20.x"]`. | `list(string)` | `[]` |
| `compatible_architectures` | CPU architectures. Valid: `x86_64`, `arm64`. | `list(string)` | `["x86_64"]` |

### Metadata & Lifecycle

| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `description` | Human-readable description of the layer. | `string` | `""` |
| `license_info` | SPDX license identifier (e.g. `MIT`, `Apache-2.0`). | `string` | `null` |
| `skip_destroy` | Retain old layer versions in AWS when a new one is published. Prevents breaking live functions. | `bool` | `false` |
| `tags` | Additional resource tags. | `map(string)` | `{}` |

### Cross-account Permissions

| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `layer_permissions` | List of cross-account permissions. See [Permission Configuration](#permission-configuration). | `list(obj)` | `[]` |

## Outputs

| Name | Description |
| :--- | :--- |
| `arn` | Full ARN including version — use in `aws_lambda_function.layers`. |
| `layer_arn` | ARN without version number. |
| `layer_name` | Name of the layer as created in AWS. |
| `version` | Published version number. |
| `created_date` | Creation date of the layer version. |
| `source_code_size` | Size of the layer zip in bytes. |
| `compatible_runtimes` | Runtimes declared as compatible. |
| `compatible_architectures` | Architectures declared as compatible. |
| `signing_job_arn` | ARN of the signing job (if layer is code-signed). |
| `signing_profile_version_arn` | ARN of the signing profile version (if code-signed). |

---

## Permission Configuration

Each entry in `layer_permissions` supports:

| Attribute | Description | Required |
| :--- | :--- | :---: |
| `statement_id` | Unique ID for the permission statement. | Yes |
| `principal` | AWS account ID or `"*"` for all accounts. | Yes |
| `organization_id` | AWS Organization ID (e.g. `o-xxxxxxxx`) — restricts grant to org members. | No |

---

## Examples

### Local zip — single runtime

```hcl
module "my_layer" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda_layer?ref=main"
  layer_name  = "utils"
  environment = "develop"

  filename         = "${path.module}/layer.zip"
  source_code_hash = filebase64sha256("${path.module}/layer.zip")

  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
  description              = "Shared utilities layer"
  skip_destroy             = true
}

# Reference in a Lambda function
resource "aws_lambda_function" "my_function" {
  ...
  layers = [module.my_layer.arn]
}
```

### S3 source — multi-runtime + arm64

```hcl
module "my_layer" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda_layer?ref=main"
  layer_name  = "dependencies"
  environment = "production"

  s3_bucket         = "my-artifacts-bucket"
  s3_key            = "layers/dependencies.zip"
  s3_object_version = "abc123"

  compatible_runtimes      = ["python3.12", "python3.11"]
  compatible_architectures = ["x86_64", "arm64"]
  description              = "Python dependencies"
  license_info             = "MIT"
  skip_destroy             = true
}
```

### Cross-account sharing

```hcl
module "my_layer" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda_layer?ref=main"
  layer_name  = "shared-utils"
  environment = "production"

  filename         = "${path.module}/layer.zip"
  source_code_hash = filebase64sha256("${path.module}/layer.zip")

  compatible_runtimes = ["nodejs20.x"]

  layer_permissions = [
    {
      statement_id = "allow-account-a"
      principal    = "111122223333"
    },
    {
      statement_id    = "allow-org"
      principal       = "*"
      organization_id = "o-xxxxxxxxxx"
    }
  ]
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
