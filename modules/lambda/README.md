# AWS Lambda Module

Standardized module for deploying AWS Lambda functions with internal IAM roles and dynamic environment variable management.

## Features
- **Internal IAM Role**: Automatically creates a dedicated execution role.
- **Dynamic Policies**: Attach multiple inline policies via the `inline_policies` variable.
- **Environment Merge**: Preserves existing environment variables while adding new ones managed by Terraform using a `null_resource` script.
- **Lifecycle Protection**: Prevents accidental code rollbacks during CI/CD deployments by ignoring changes to `filename`, `source_code_hash`, and `environment`.

## Usage
```hcl
module "my_lambda" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=v1.0.0"

  function_name = "my-service"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  environment   = "production"
  
  inline_policies = [
    {
      name   = "S3Access"
      policy = jsonencode({ ... })
    }
  ]
}
```

## 🔀 Multi-Lambda Pattern
To deploy multiple functions using this module, use the `for_each` meta-argument in your stack:

```hcl
locals {
  functions = {
    "api-users" = { handler = "users.handler", memory = 256 }
    "api-auth"  = { handler = "auth.handler",  memory = 512 }
  }
}

module "lambdas" {
  for_each = local.functions
  source   = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=v1.0.0"

  function_name = each.key
  handler       = each.value.handler
  memory_size   = each.value.memory
  environment   = var.environment
}
```

## Inputs
| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `function_name` | Base name of the function | `string` | **Yes** | - |
| `environment` | Deployment environment (dev/prod) | `string` | **Yes** | - |
| `handler` | Function entry point | `string` | No | `index.handler` |
| `runtime` | Lambda runtime | `string` | No | `nodejs18.x` |
| `memory_size` | Memory allocation in MB | `number` | No | `128` |
| `timeout` | Execution timeout in seconds | `number` | No | `10` |
| `inline_policies` | List of {name, policy} objects | `list` | No | `[]` |
| `environment_variables` | Map of environment variables | `map` | No | `{}` |

## Outputs
| Name | Description |
|---|---|
| `function_name` | Name of the created function |
| `function_arn` | ARN of the created function |
| `role_name` | Name of the IAM role |
| `role_arn` | ARN of the IAM role |
