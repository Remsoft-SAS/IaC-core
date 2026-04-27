# 🏗️ Remsoft IaC-Core Framework

Standardized Infrastructure as Code library for Remsoft SAS projects. This repository contains "Advanced Grade" Terraform modules designed for high availability, security, and developer productivity.

## 🌟 Framework Philosophy
- **Smart Automation:** Modules detect context and autoconfigure permissions (e.g., Lambda + SQS).
- **Security by Default:** Integrated encryption (KMS), protection (WAF/PITR), and private access (OAC).
- **Environment Driven:** Consistent naming and tagging following the `project-environment` pattern.
- **Micro-Infrastructure Ready:** Designed for decoupled, event-driven architectures.

## 📦 Available Modules

| Module | Status | Core Features |
| :--- | :--- | :--- |
| [**Lambda**](./modules/lambda) | 💎 Advanced | Smart trigger detection (SQS, SNS, API, DynamoDB), Auto-IAM. |
| [**API Gateway**](./modules/api_gateway) | 💎 Advanced | Cognito/Lambda Authorizers, CORS automation, Regional endpoints. |
| [**CloudFront**](./modules/cloudfront) | 💎 Advanced | Hybrid Origins (S3+API), SPA support, SSL automation (us-east-1). |
| [**DynamoDB**](./modules/dynamodb) | 💎 Advanced | Dynamic GSI/LSI, PITR protection, Streams, TTL support. |
| [**SQS**](./modules/sqs) | 💎 Advanced | Automated SNS Subscription, Built-in DLQ, KMS encryption. |
| [**SNS**](./modules/sns) | 💎 Advanced | Centralized Hub, Dynamic access policies, KMS encryption. |
| [**S3**](./modules/s3) | ✅ Standard | Bucket policies, OAC support, CORS for static sites. |
| [**Cognito**](./modules/cognito) | ✅ Standard | User Pools, Social Auth (Google/MS), DNS/ACM integration. |

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
