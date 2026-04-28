# 🆔 AWS Cognito Identity Module (Advanced Edition)

The most comprehensive Terraform module to manage AWS Cognito User Pools. Designed for **Enterprise Identity Management**, it automates security, triggers, social federation, and custom schema definitions.

## 🌟 Key Features
- **Dynamic Schema Management:** Add custom attributes via variables without modifying the core code.
- **Elite Custom Auth (OTP):** Built-in wiring for passwordless authentication flows.
- **Enterprise Security:** Support for Multi-Factor Authentication (MFA) and advanced security modes.
- **Zero-Touch DNS:** Automatic Route53/ACM integration for custom domains.
- **Flexible Auth Flows:** Fine-grained control over `explicit_auth_flows`.

## 📥 Full Reference: Variables

### 🏗️ Base Configuration
| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `pool_name` | Base name for the User Pool | `string` | - |
| `environment` | develop / production | `string` | - |
| `username_attributes` | Attributes used for login (`email`, `phone_number`) | `list(string)` | `["email"]` |
| `explicit_auth_flows` | Allowed auth flows (`ALLOW_CUSTOM_AUTH`, `ALLOW_USER_SRP_AUTH`, etc.) | `list(string)` | `["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]` |

### 🧠 Custom Triggers (Lambda)
| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `lambda_pre_signup_arn` | ARN for Pre Sign-up trigger | `string` | `null` |
| `lambda_define_auth_arn` | ARN for Define Auth Challenge | `string` | `null` |
| `lambda_create_auth_arn` | ARN for Create Auth Challenge | `string` | `null` |
| `lambda_verify_auth_arn` | ARN for Verify Auth Challenge | `string` | `null` |
| `enable_pre_signup` | Enable Pre Sign-up flag | `bool` | `false` |
| `enable_define_auth` | Enable Define Auth flag | `bool` | `false` |
| `enable_create_auth` | Enable Create Auth flag | `bool` | `false` |
| `enable_verify_auth` | Enable Verify Auth flag | `bool` | `false` |

### 🔒 Security & Password Policy
| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `password_minimum_length` | Minimum password length | `number` | `8` |
| `mfa_configuration` | MFA mode (`OFF`, `ON`, `OPTIONAL`) | `string` | `OFF` |
| `advanced_security_mode` | `OFF`, `AUDIT`, `ENFORCED` | `string` | `OFF` |

### 🌐 DNS & Social Identity
| Name | Description | Type | Default |
| :--- | :--- | :--- | :--- |
| `domain_name` | Root domain for Route53 | `string` | `""` |
| `custom_domain` | Full custom domain for auth | `string` | `""` |
| `google_client_id` | Google OAuth Client ID | `string` | `""` |
| `google_client_secret` | Google OAuth Client Secret | `string` | `""` |
| `callback_urls` | Allowed callback URLs | `list(string)` | `[]` |

## 🧠 Elite OTP Configuration (Passwordless)

To implement a passwordless flow, use:

```hcl
module "cognito" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name   = "my-app"
  environment = "develop"

  # Enforce custom auth only
  explicit_auth_flows = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  
  enable_define_auth = true
  lambda_define_auth_arn = module.lambdas["define"].arn
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
