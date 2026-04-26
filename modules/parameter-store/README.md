# AWS Parameter Store Module

Manages AWS SSM Parameters for centralized configuration.

## Features
- **Standardized Naming**: Parameters follow a `/project/env/name` convention if desired.
- **Secure Strings**: Support for encrypted parameters.

## Inputs
| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `parameter_name` | Name of the parameter | `string` | **Yes** | - |
| `environment` | Deployment environment | `string` | **Yes** | - |
| `value` | Value of the parameter | `string` | **Yes** | - |
| `type` | Type (String, SecureString) | `string` | No | `SecureString` |

## Outputs
| Name | Description |
|---|---|
| `parameter_arn` | ARN of the parameter |
| `parameter_name` | Final name used in AWS |
