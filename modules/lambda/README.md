# AWS Lambda Module

Standardized module for deploying AWS Lambda functions with internal IAM roles and dynamic environment variable management.

## Features
- **Internal IAM Role**: Automatically creates a dedicated execution role.
- **Dynamic Policies**: Attach multiple inline policies via the `inline_policies` variable.
- **Environment Merge**: Preserves existing environment variables while adding new ones managed by Terraform using a `null_resource` script.
- **Lifecycle Protection**: Prevents accidental code rollbacks during CI/CD deployments by ignoring changes to `filename`, `source_code_hash`, and `environment`.

## Inputs
| Name | Description | Type | Default |
|---|---|---|---|
| `function_name` | Base name of the function | `string` | - |
| `handler` | Function entry point | `string` | `index.handler` |
| `runtime` | Lambda runtime | `string` | `nodejs18.x` |
| `environment` | Deployment environment (dev/prod) | `string` | - |
| `inline_policies` | List of {name, policy} objects for the IAM role | `list` | `[]` |

## Outputs
| Name | Description |
|---|---|
| `function_name` | Name of the created function |
| `function_arn` | ARN of the created function |
| `role_name` | Name of the IAM role |
| `role_arn` | ARN of the IAM role |
