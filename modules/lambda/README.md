# 🚀 AWS Lambda Function Module (Smart Edition)

High-performance Terraform module to manage AWS Lambda functions with **Intelligent Resource Detection**. It automatically configures permissions and event mappings based on the provided Event Source ARN.

## 🌟 Key Features
- **Smart Event Wiring:** Automatically detects the service type (SQS, SNS, API Gateway, etc.) and configures the appropriate execution model (Push or Pull).
- **Auto-Provisioned IAM Permissions:** Grants necessary read/write permissions for SQS and DynamoDB Streams without manual policy writing.
- **Unified Trigger Logic:** Use a single variable `event_source_arn` for almost any AWS trigger.
- **CI/CD Friendly:** Environment variables are smartly merged to prevent overwriting manual or external deployment updates.

## 📋 Smart Event Integration

The module analyzes the `event_source_arn` and automates the following setups:

| Service | Detection Pattern | Model | Automation Highlights |
| :--- | :--- | :---: | :--- |
| **SQS** | `:sqs:` | Pull | `event_source_mapping` + `ReceiveMessage`, `DeleteMessage` permissions. |
| **DynamoDB** | `:dynamodb:` | Pull | `event_source_mapping` + `GetRecords`, `DescribeStream` permissions. |
| **API Gateway** | `execute-api` | Push | `aws_lambda_permission` (Allow Invoke from APIGW). |
| **SNS** | `:sns:` | Push | `aws_lambda_permission` (Allow Invoke from SNS). |
| **S3** | `arn:aws:s3:::` | Push | `aws_lambda_permission` (Allow Invoke from S3). |

## 🛠️ Usage Examples

### SQS Consumer (Pull Model)
```hcl
module "sqs_worker" {
  source           = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name    = "worker"
  environment      = "production"
  event_source_arn = "arn:aws:sqs:us-east-1:123456789012:my-queue"
}
```

### API Gateway Trigger (Push Model)
```hcl
module "api_handler" {
  source           = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name    = "api-handler"
  environment      = "develop"
  # Smart detection of API GW ARN
  event_source_arn = "arn:aws:execute-api:us-east-1:123456789012:api-id/*/*/*"
}
```

## 📥 Inputs Summary

| Name | Description | Default |
| :--- | :--- | :--- |
| `function_name` | Base name for the Lambda | - |
| `environment` | develop/production | - |
| **`event_source_arn`** | **The ARN of the trigger (S3, SQS, SNS, etc.)** | `null` |
| `event_source_batch_size` | Number of records per batch (for SQS/DynamoDB) | `1` |
| `inline_policies` | Additional custom IAM policies | `[]` |

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
