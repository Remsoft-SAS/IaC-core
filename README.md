# AWS Infrastructure as Code (IaC) Core

A centralized library of production-ready, reusable Terraform modules for AWS. This repository provides the building blocks for all REMSOFT infrastructure, ensuring security, standardization, and rapid deployment.

## 🚀 Principles
- **Self-Contained**: Modules manage their own IAM roles and security groups internally.
- **Agnostic**: Logic is decoupled from specific projects using variables.
- **Environment-Aware**: Automatic naming conventions based on `${var.environment}`.
- **Serverless First**: Optimized for Lambda, API Gateway, DynamoDB, and S3 architectures.

## 📦 Available Modules

| Module | Description |
|---|---|
| [Lambda](./modules/lambda) | AWS Lambda with internal IAM, dynamic policies, and env merging. |
| [API Gateway](./modules/api_gateway) | REST API with CloudWatch logging, CORS, and Throttling. |
| [S3](./modules/s3) | Secure buckets with versioning, encryption, and bucket policies. |
| [DynamoDB](./modules/dynamodb) | NoSQL tables with PITR, autoscaling, and secondary indexes. |
| [Auth](./modules/auth) | Amazon Cognito User Pools and Clients for authentication. |
| [Route 53](./modules/route53) | DNS Hosted Zones and records management. |
| [ACM](./modules/acm) | SSL/TLS certificates with automatic DNS validation. |
| [CloudFront](./modules/cloudfront) | CDN for S3 and custom origins with OAC support. |
| [SQS](./modules/sqs) | Simple Queue Service with Dead Letter Queues (DLQ). |
| [Parameter Store](./modules/parameter-store) | AWS SSM Parameters for configuration management. |

## 🛠️ Usage

Reference modules directly from GitHub in your Terraform stacks:

```hcl
module "service_api" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=v1.0.0"

  function_name = "my-api"
  environment   = "production"
  # ... other inputs
}
```

## 🔐 Security
All modules follow AWS security best practices:
- Encryption at rest (AES-256 / KMS).
- Public access blocked by default (S3).
- Least privilege IAM roles.
- SSL/TLS enforcement.

## 📄 License
Managed by Remsoft SAS. All rights reserved.
