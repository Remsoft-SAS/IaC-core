# Centralized Infrastructure Stacks (IaC-core)

This repository contains two levels of Terraform code:
1.  **/modules**: Atomic components (Lambda, S3, Cognito, etc.) designed for high reusability.
2.  **/stacks**: Composition of modules that represent a complete functional infrastructure unit (e.g., Bootstrap, DNS).

## 🚀 How to use Stacks

Stacks are designed to be called from a project-specific repository (e.g., `rempays_iac-base`). This keeps your project repo agnostic and clean.

### Standard Implementation Example:

```hcl
module "dns" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//stacks/dns-certificates?ref=main"

  domain_name = "example.com"
  environment = "production"
  aws_region  = "us-east-1"
}
```

## 📂 Repository Structure

- [🏗️ **/stacks**](./stacks/README.md) - High-level infrastructure compositions (Bootstrap, DNS).
- [🧩 **/modules**](#-available-modules) - Atomic, reusable components.

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

## 🏗️ Available Stacks

---

## 🔗 Related Repositories

- [🚀 **reusable-workflows-core**](https://github.com/Remsoft-SAS/reusable-workflows-core) - The CI/CD engine that triggers these stacks.
- [📦 **rempays_iac-base**](https://github.com/Remsoft-SAS/rempays_iac-base) - An example of a project-specific repository using these stacks.

## 📝 Best Practices
1.  **Versioning**: Always use `?ref=main` or a specific tag in the `source` URL.
2.  **Agnosticism**: Do not hardcode project names inside stacks; use variables.
3.  **Outputs**: Stacks should provide the necessary outputs (ARNs, IDs) for other microservices to consume via SSM or Data Sources.

---

remsoft
