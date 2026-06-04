# Parameter Store Module

Manages AWS SSM Parameters (String, StringList, SecureString) for configuration and secrets.

Supports two lifecycle modes:
- **Standard** — Terraform fully manages the value (default).
- **External** — Terraform creates the parameter but ignores future value changes, for secrets rotated outside Terraform (e.g. manually, via Lambda, AWS Secrets Manager rotation).

---

## Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `environment` | Target environment (develop/production) | `string` | Yes | — |
| `parameters` | List of parameters to create | `list(object)` | Yes | — |

### Parameter Object

| Field | Description | Type | Required | Default |
|---|---|---|---|---|
| `name` | Full parameter name (e.g. `/app/env/key`) | `string` | Yes | — |
| `value` | Value of the parameter | `string` | Yes | — |
| `type` | `String`, `StringList`, or `SecureString` | `string` | Yes | — |
| `description` | Human-readable description | `string` | No | `"Managed by Terraform"` |
| `key_id` | KMS key ID or ARN for `SecureString` encryption | `string` | No | `null` (uses AWS default key) |
| `tier` | `Standard` or `Advanced`. Auto-upgraded to `Advanced` if value exceeds 4096 bytes | `string` | No | `"Standard"` |
| `data_type` | `text` or `aws:ec2:image` (for AMI ID parameters) | `string` | No | `"text"` |
| `ignore_value_changes` | When `true`, Terraform ignores future changes to the value (external rotation mode) | `bool` | No | `false` |
| `tags` | Additional tags to merge onto the parameter | `map(string)` | No | `{}` |

---

## Outputs

| Name | Description |
|---|---|
| `parameters` | Map of `name => ARN` for all created parameters |
| `parameter_names` | List of all parameter names |
| `parameter_arns` | List of all parameter ARNs |
| `parameter_versions` | Map of `name => version` for all created parameters |

---

## Usage Examples

### Basic — String parameter

```hcl
module "parameters" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/parameter-store?ref=main"

  environment = "develop"
  parameters = [
    {
      name  = "/myapp/develop/api_url"
      value = "https://api.example.com"
      type  = "String"
    }
  ]
}
```

### SecureString with custom KMS key

```hcl
module "parameters" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/parameter-store?ref=main"

  environment = "production"
  parameters = [
    {
      name        = "/myapp/production/db_password"
      value       = "initial-placeholder"
      type        = "SecureString"
      key_id      = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"
      description = "Database password — rotated externally"
      ignore_value_changes = true
    }
  ]
}
```

### Mixed — some Terraform-managed, some externally rotated

```hcl
module "parameters" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/parameter-store?ref=main"

  environment = "production"
  parameters = [
    {
      name  = "/myapp/production/feature_flag"
      value = "true"
      type  = "String"
    },
    {
      name                 = "/myapp/production/api_secret"
      value                = "placeholder"
      type                 = "SecureString"
      ignore_value_changes = true
      description          = "Rotated by Lambda — Terraform ignores value drift"
    }
  ]
}
```

### AMI ID parameter

```hcl
module "parameters" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/parameter-store?ref=main"

  environment = "production"
  parameters = [
    {
      name      = "/myapp/production/golden_ami"
      value     = "ami-0abcdef1234567890"
      type      = "String"
      data_type = "aws:ec2:image"
    }
  ]
}
```

### Using outputs to grant Lambda access

```hcl
module "parameters" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/parameter-store?ref=main"
  environment = var.environment
  parameters  = [...]
}

module "my_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "my-function"
  environment   = var.environment

  inline_policies = [
    {
      name = "SSMReadPolicy"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
          Resource = module.parameters.parameter_arns
        }]
      })
    }
  ]
}
```

---

## Notes

- **Tier auto-upgrade**: If a parameter value exceeds 4096 bytes, the module automatically uses the `Advanced` tier regardless of the `tier` field.
- **KMS**: When `type = "SecureString"` and no `key_id` is provided, AWS uses the default SSM KMS key (`alias/aws/ssm`). To use a customer-managed key, pass the key ARN via `key_id`. Ensure the consumer role also has `kms:Decrypt` on that key.
- **External rotation**: Set `ignore_value_changes = true` for secrets that are rotated outside Terraform. The parameter is created with the provided `value` as the initial value, and Terraform will not overwrite it on subsequent applies.
- **Path convention**: Using path-style names (e.g. `/app/env/key`) is recommended as it enables `ssm:GetParametersByPath` for IAM scoping and bulk reads.
