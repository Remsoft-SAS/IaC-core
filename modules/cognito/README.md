# AWS Cognito Module

Generic and fully configurable Amazon Cognito User Pool module.

## Features
- **Flexible Authentication**: Supports both standard password-based login and custom authentication flows (OTP/Magic Link).
- **Agnostic Lambda Triggers**: All triggers (Pre-signup, Define/Create/Verify Challenge, etc.) are optional and variable-driven.
- **Configurable Password Policy**: Full control over complexity requirements.
- **App Client**: Automatically creates a User Pool Client with configurable authentication flows.

## Inputs
| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `pool_name` | Base name for the User Pool | `string` | **Yes** | - |
| `environment` | Deployment environment | `string` | **Yes** | - |
| `username_attributes` | Attributes for login (email, phone_number) | `list` | No | `["phone_number"]` |
| `password_minimum_length` | Minimum length | `number` | No | `8` |
| `password_require_uppercase` | Require uppercase | `bool` | No | `true` |
| `lambda_define_auth_arn` | Define challenge trigger | `string` | No | `null` |
| `lambda_create_auth_arn` | Create challenge trigger | `string` | No | `null` |
| `lambda_verify_auth_arn` | Verify challenge trigger | `string` | No | `null` |

## Outputs
| Name | Description |
|---|---|
| `user_pool_id` | ID of the User Pool |
| `user_pool_arn` | ARN of the User Pool |
| `client_id` | ID of the User Pool Client |
