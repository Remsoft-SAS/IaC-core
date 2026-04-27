# 🏗️ Remsoft IaC-Core Framework

Standardized Infrastructure as Code library for Remsoft SAS projects. This repository contains **Advanced Grade** Terraform modules designed for high availability, enterprise security, and developer productivity.

## 🌟 Framework Philosophy
- **Smart Automation:** Modules detect context and autoconfigure permissions and wiring (e.g., Lambda + SQS, Cognito + Route53).
- **Security by Default:** Integrated encryption (KMS), advanced protection (WAF/PITR), and private access control (OAC).
- **Environment Driven:** Consistent naming and tagging following the `project-environment` pattern.
- **Enterprise Ready:** Designed for high-scale, decoupled, and event-driven architectures.

## 📦 Available Modules

| Module | Status | Core Features |
| :--- | :--- | :--- |
| [**Lambda**](./modules/lambda) | 💎 Advanced | Smart trigger detection (SQS, SNS, API, DynamoDB), Auto-IAM. |
| [**API Gateway**](./modules/api_gateway) | 💎 Advanced | Cognito/Lambda Authorizers, CORS automation, Regional endpoints. |
| [**CloudFront**](./modules/cloudfront) | 💎 Advanced | Hybrid Origins (S3+API), SPA support, SSL automation (us-east-1). |
| [**DynamoDB**](./modules/dynamodb) | 💎 Advanced | Dynamic GSI/LSI, PITR protection, Streams, TTL support. |
| [**Cognito**](./modules/cognito) | 💎 Advanced | Multi-provider Social Auth, Advanced Security, Custom Schema, MFA. |
| [**S3**](./modules/s3) | 💎 Advanced | Smart OAC Integration, Multi-tier Lifecycle (Glacier), Static Hosting. |
| [**SQS**](./modules/sqs) | 💎 Advanced | Automated SNS Subscription, Built-in DLQ, KMS encryption. |
| [**SNS**](./modules/sns) | 💎 Advanced | Centralized Hub, Dynamic access policies, KMS encryption. |

## 🚀 Getting Started

To use these modules, reference them in your Terraform code using the git source:

```hcl
module "my_lambda" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "example"
  environment   = "develop"
  # ... other variables
}
```

## 🛠️ Contribution
- All modules must include a professional `README.md` in English.
- Use strict typing for variables (`list(object)`) where possible.
- Ensure backward compatibility or document breaking changes.

---
*Created and maintained by Remsoft SAS Engineering Team.*
