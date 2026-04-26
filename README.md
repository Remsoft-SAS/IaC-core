# 🏢 Remsoft Infrastructure Core (Modules Library)

This repository is a centralized library of atomic, reusable Terraform modules. It contains the fundamental "bricks" used to build any project infrastructure within the organization.

## 📂 Repository Structure

- [🧩 **/modules**](#-available-modules) - Atomic, reusable components designed for high flexibility.
- [📝 **How to contribute**](./CONTRIBUTING.md) - Guide for adding new modules.

---

## 🧩 Available Modules

| Module | Purpose | Required Inputs (Core) |
|---|---|---|
| [λ **Lambda**](./modules/lambda/README.md) | Serverless functions | `function_name`, `handler`, `runtime` |
| [📂 **S3**](./modules/s3/README.md) | Secure storage | `bucket_name`, `environment` |
| [🔗 **API Gateway**](./modules/api_gateway/README.md) | REST APIs | `api_name`, `endpoints` |
| [🔐 **Cognito**](./modules/cognito/README.md) | Authentication | `pool_name`, `environment` |
| [📊 **DynamoDB**](./modules/dynamodb/README.md) | NoSQL Database | `table_name`, `hash_key`, `attributes` |
| [🌐 **CloudFront**](./modules/cloudfront/README.md) | CDN / Frontend | `s3_bucket_domain_name`, `comment` |
| [📜 **ACM**](./modules/acm/README.md) | SSL Certificates | `domain_name`, `zone_id` |
| [📍 **Route53**](./modules/route53/README.md) | DNS Management | `domain_name`, `environment` |
| [📨 **SQS**](./modules/sqs/README.md) | Message Queues | `queue_name`, `environment` |
| [🔑 **Parameter Store**](./modules/parameter-store/README.md) | Configuration | `parameters`, `environment` |

---

## 🔗 Related Repositories

- [🏗️ **IaC-base**](https://github.com/Remsoft-SAS/IaC-base) - The blueprints (Stacks) that use these modules.
- [🚀 **reusable-workflows-core**](https://github.com/Remsoft-SAS/reusable-workflows-core) - The CI/CD engine.

---

remsoft
