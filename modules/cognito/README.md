# 🆔 AWS Cognito Identity Module (Advanced Edition)

The most comprehensive Terraform module to manage AWS Cognito User Pools. Designed for **Enterprise Identity Management**, it automates security, triggers, social federation, and custom schema definitions.

## 🌟 Key Features
- **Dynamic Schema Management:** Add custom attributes (e.g., `company_id`, `role`) via variables without modifying the core code.
- **Enterprise Security:** Support for Multi-Factor Authentication (MFA), advanced risk detection, and device tracking.
- **Full Social Federation:** Built-in support for Google, Microsoft (Azure AD), and Facebook.
- **Zero-Touch DNS:** Automatic Route53 and ACM integration for custom authentication domains (e.g., `auth.remsoft.io`).
- **Smart Triggering:** Automatically grants invocation permissions to Lambda triggers (Pre-SignUp, Custom Auth, Migration).
- **Production Ready:** Environment-aware deletion protection and advanced password policies.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `pool_name` | Base name for the User Pool. | `string` | - | **Yes** |
| `environment` | develop/production. | `string` | - | **Yes** |
| `custom_attributes` | Custom data schema. [See Schema Details](#-custom-schema-setup) | `list(obj)` | `[]` | No |
| `mfa_configuration` | `OFF`, `ON`, or `OPTIONAL`. | `string` | `OFF` | No |
| `advanced_security_mode` | `AUDIT` or `ENFORCED`. | `string` | `OFF` | No |
| `custom_domain` | Custom domain for auth. | `string` | `""` | No |
| `google_client_id` | Google Client ID for federation. | `string` | `""` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `user_pool_id` | The ID of the User Pool. |
| `user_pool_arn` | The ARN of the User Pool. |
| `client_id` | The ID of the primary App Client. |
| `auth_domain` | The full custom auth domain (if configured). |

---

## 🧠 Custom Schema Setup

You can define custom attributes to store business-specific data.

```hcl
module "auth" {
  source    = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name = "myapp"
  
  custom_attributes = [
    {
      name                = "company_id"
      attribute_data_type = "String"
      mutable             = true
      required            = false
    },
    {
      name                = "is_admin"
      attribute_data_type = "Boolean"
      mutable             = true
      required            = false
    }
  ]
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
