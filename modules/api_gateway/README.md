# AWS API Gateway Module

Creates a REST API with CloudWatch logging, CORS support, and method throttling.

## Features
- **Internal IAM for Logs**: Manages the CloudWatch role and account-wide settings optionally.
- **Dynamic Endpoints**: Define multiple endpoints with Lambda integrations in a single list.
- **Throttling**: Configures rate and burst limits for the API stage.
- **CORS**: Built-in support for Cross-Origin Resource Sharing.

## Inputs
| Name | Description | Type | Default |
|---|---|---|---|
| `api_name` | Name of the API | `string` | - |
| `endpoints` | List of path/method/lambda configurations | `list` | - |
| `enable_access_logs` | Enable CloudWatch access logging | `bool` | `false` |
| `manage_api_gateway_account` | Manage the global CloudWatch role for the account | `bool` | `false` |

## Outputs
| Name | Description |
|---|---|
| `api_id` | ID of the REST API |
| `api_url` | Base URL of the API stage |
| `execution_arn` | Execution ARN for Lambda permissions |
