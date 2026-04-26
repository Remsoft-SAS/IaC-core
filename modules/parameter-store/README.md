# Parameter Store Module

Manages AWS SSM Parameters (String, StringList, SecureString) for configuration and secrets.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `parameters` | List of parameters to create | `list(object)` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |

### Parameter Object structure:
- `name`: Name of the parameter.
- `value`: Value of the parameter.
- `type`: `String`, `StringList`, or `SecureString`.
- `description`: (Optional) Description.
- `key_id`: (Optional) KMS key for `SecureString`.

## 📤 Outputs

| Name | Description |
|---|---|
| `parameters` | Map of created parameters (name => arn) |
| `parameter_names` | List of names of the created parameters |
| `parameter_arns` | List of ARNs of the created parameters |

## 📝 Usage Example

```hcl
module "parameters" {
  source = "../../modules/parameter-store"

  environment = "production"
  parameters = [
    {
      name  = "/rempays/api/key"
      value = "super-secret-value"
      type  = "SecureString"
    }
  ]
}
```
