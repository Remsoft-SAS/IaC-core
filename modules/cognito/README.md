# 🔐 AWS Cognito User Pool & Client Module

High-performance Terraform module to manage AWS Cognito infrastructure with native support for Social Identity Providers, Custom Auth Flows, and Automated DNS/SSL management.

## ⚠️ Prerequisites
To enable **Smart DNS Automation**, the following resources must exist beforehand:
1. **Route53 Hosted Zone:** A hosted zone for the `domain_name` must be active in your AWS account.
2. **ACM Certificate:** A wildcard certificate (`*.domain_name`) must be **ISSUED** in the **us-east-1** region (CloudFront/Cognito requirement).
3. **IAM Permissions:** The execution identity must have permissions to read Route53 and ACM resources.

*Failure to meet these prerequisites will cause the `data` lookups to fail during the `terraform plan` phase.*

## 🚀 Key Features
- **Zero-Config DNS/ACM:** Automatic discovery of Route53 Zones and Wildcard Certificates via `domain_name`.
- **Custom Domain Orchestration:** Native management of Cognito Custom Domains and Route53 Alias records.
- **Smart Lambda Permissions:** Automatic `aws_lambda_permission` creation for all provided triggers.
- **Native Social Integration:** Built-in OIDC support for Google and Microsoft.
- **Auto-Provisioned Client:** The User Pool Client automatically enables all active identity providers.

## 📋 Technical Usage

### Basic (AWS Native Auth)
```hcl
module "cognito" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name   = "my-app"
  environment = "production"
}
```

### Advanced (Elite Auth + Social)
```hcl
module "cognito" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"
  pool_name     = "my-app"
  environment   = "production"
  domain_name   = "example.com"
  custom_domain = "auth.example.com"

  # Social Credentials
  google_client_id     = "GOOGLE_ID"
  google_client_secret = "GOOGLE_SECRET"

  # OTP / Custom Auth Triggers
  lambda_create_auth_arn = "arn:aws:lambda:..."
}
```

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `pool_name` | Base name for the User Pool | `string` | - | **Yes** |
| `environment` | Deployment environment (develop/production) | `string` | - | **Yes** |
| `domain_name` | Base domain for DNS/ACM discovery | `string` | `""` | No |
| `custom_domain` | Custom subdomain for Cognito (e.g. auth.xxx) | `string` | `""` | No |
| `username_attributes` | Attributes used for sign-in | `list(string)` | `["phone_number"]` | No |
| `google_client_id` | Google OAuth Client ID | `string` | `""` | No |
| `google_client_secret` | Google OAuth Client Secret | `string` | `""` | No |
| `microsoft_client_id` | Microsoft Azure Client ID | `string` | `""` | No |
| `microsoft_client_secret` | Microsoft Azure Client Secret | `string` | `""` | No |
| `lambda_pre_signup_arn` | ARN for Pre Sign-up trigger | `string` | `null` | No |
| `lambda_define_auth_arn` | ARN for Define Auth Challenge trigger | `string` | `null` | No |
| `lambda_create_auth_arn` | ARN for Create Auth Challenge trigger | `string` | `null` | No |
| `lambda_verify_auth_arn` | ARN for Verify Auth Response trigger | `string` | `null` | No |
| `callback_urls` | Allowed OAuth callback URLs | `list(string)` | `[]` | No |
| `logout_urls` | Allowed OAuth logout URLs | `list(string)` | `[]` | No |
| `tags` | Additional tags for resources | `map(string)` | `{}` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `user_pool_id` | Unique ID of the Cognito User Pool |
| `user_pool_arn` | Amazon Resource Name (ARN) of the User Pool |
| `user_pool_endpoint` | Endpoint URL of the User Pool |
| `user_pool_client_id` | ID of the User Pool Client |
| `user_pool_client_secret` | Secret of the User Pool Client (Sensitive) |

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
