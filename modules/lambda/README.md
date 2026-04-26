# Lambda Module

Highly configurable module for deploying AWS Lambda functions with integrated IAM roles and CloudWatch Log Groups.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `function_name` | Name of the Lambda function | `string` | **Yes** | - |
| `handler` | Entry point for the function | `string` | **Yes** | - |
| `runtime` | Language runtime (e.g., `nodejs22.x`) | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `memory_size` | Memory size in MB | `number` | No | `128` |
| `timeout` | Timeout in seconds | `number` | No | `30` |
| `env_vars` | Environment variables | `map(string)` | No | `{}` |
| `layers` | List of Lambda Layer ARNs | `list(string)` | No | `[]` |
| `log_retention_days` | CloudWatch log retention in days | `number` | No | `7` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `function_name` | Final name of the Lambda function |
| `function_arn` | ARN of the Lambda function |
| `invoke_arn` | Invoke ARN of the Lambda function |
| `role_arn` | ARN of the IAM execution role |

## 📝 Usage Example

```hcl
module "lambda" {
  source = "../../modules/lambda"

  function_name = "process-payment"
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  environment   = "production"
  
  env_vars = {
    DB_URL = "postgres://..."
  }
}
```
