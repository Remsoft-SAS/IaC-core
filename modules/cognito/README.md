# Cognito Module (AWS Auth)

Manages AWS Cognito User Pools and Clients for secure authentication.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `pool_name` | Base name of the Cognito User Pool | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `username_attributes` | Attributes used for login (phone_number, email) | `list(string)` | No | `["phone_number"]` |
| `password_minimum_length` | Minimum password length | `number` | No | `8` |
| `temp_password_validity_days` | Days of validity for temporary passwords | `number` | No | `7` |
| `explicit_auth_flows` | Allowed authentication flows | `list(string)` | No | `["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `user_pool_id` | Cognito User Pool ID |
| `user_pool_arn` | Cognito User Pool ARN |
| `user_pool_client_id` | Cognito User Pool Client ID |
| `user_pool_endpoint` | Cognito User Pool endpoint |

## 📝 Usage Example

```hcl
module "auth" {
  source = "../../modules/cognito"

  pool_name   = "rempays-users"
  environment = "production"
  username_attributes = ["email", "phone_number"]
}
```
