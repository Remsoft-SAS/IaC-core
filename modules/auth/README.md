# AWS Auth Module (Cognito)

Standardized Cognito User Pool for custom authentication flows, optimized for OTP (One-Time Password) or Magic Link login systems.

## Features
- **Custom Auth Triggers**: Built-in configuration for Lambda triggers (Pre-signup, Define/Create/Verify Challenge).
- **Flexible Attributes**: Supports phone_number and email as primary login attributes.
- **App Client**: Automatically creates an app client with no-password authentication enabled.
- **Permissive Password Policy**: Configured to stay out of the way for OTP-only systems.

## ⚠️ Important Note
This module requires external Lambda functions to handle the custom authentication logic. Ensure you have the ARNs for the `define`, `create`, and `verify` challenge triggers.

## Inputs
| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `pool_name` | Name of the User Pool | `string` | **Yes** | - |
| `environment` | Deployment environment | `string` | **Yes** | - |
| `username_attributes` | Attributes used for login | `list` | No | `["phone_number"]` |
| `lambda_pre_signup_arn` | Pre-signup trigger ARN | `string` | No | `null` |
| `lambda_define_auth_arn` | Define challenge trigger ARN | `string` | **Yes** | - |
| `lambda_create_auth_arn` | Create challenge trigger ARN | `string` | **Yes** | - |
| `lambda_verify_auth_arn` | Verify challenge trigger ARN | `string` | **Yes** | - |

## Outputs
| Name | Description |
|---|---|
| `user_pool_id` | ID of the User Pool |
| `user_pool_arn` | ARN of the User Pool |
| `client_id` | ID of the App Client |
