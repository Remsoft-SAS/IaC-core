# 🚀 AWS Lambda Function Module (Ultimate Smart Edition)

Professional Terraform module to manage AWS Lambda functions with **Intelligent Resource Detection**. This module automates the "wiring" between your function and various AWS services, handling both execution models (Pull and Push) seamlessly.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `function_name` | Base name for the Lambda function. | `string` | - | **Yes** |
| `environment` | Deployment environment (develop/production). | `string` | - | **Yes** |
| `event_source_arn` | ARN of the trigger. [See Smart Integration Details](#-smart-event-integration-details) | `string` | `null` | No |
| `event_source_type` | Explicit trigger type (`sqs`, `dynamodb`, `apigateway`, `sns`, `s3`). **Crucial to avoid "known after apply" errors.** | `string` | `null` | No |
| `event_source_batch_size` | Number of records per batch (for SQS/DynamoDB). | `number` | `1` | No |
| `handler` | Function entry point. | `string` | `index.handler` | No |
| `runtime` | Execution runtime. | `string` | `nodejs22.x` | No |
| `memory_size` | Allocated memory in MB. | `number` | `128` | No |
| `timeout` | Execution timeout in seconds. | `number` | `30` | No |
| `environment_variables` | Map of environment variables. | `map(string)` | `{}` | No |
| `inline_policies` | Additional IAM policies. [See Extending Permissions](#-extending-permissions) | `list(object)` | `[]` | No |
| `vpc_config` | VPC subnet and security group IDs. | `object` | `null` | No |
| `log_retention_days` | CloudWatch log retention period. | `number` | `7` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `function_name` | Final calculated name of the function. |
| `function_arn` | Amazon Resource Name (ARN) of the function. |
| `invoke_arn` | ARN used to invoke the function (e.g., via API Gateway). |
| `role_name` | Name of the IAM execution role created. |
| `role_arn` | ARN of the IAM execution role. |
| `log_group_name` | Name of the CloudWatch Log Group. |

---

## 🧠 Smart Event Integration (Details)

The module analyzes the `event_source_arn` string to detect the service type and automatically configures the infrastructure requirements.

### Supported Services & Automated Actions

| Service | Pattern Detected | Model | Automatic Setup | Default Permissions Granted |
| :--- | :--- | :---: | :--- | :--- |
| **SQS** | `:sqs:` | **Pull** | `event_source_mapping` | `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes` |
| **DynamoDB** | `:dynamodb:` | **Pull** | `event_source_mapping` | `dynamodb:GetRecords`, `dynamodb:GetShardIterator`, `dynamodb:DescribeStream`, `dynamodb:ListStreams` |
| **API Gateway** | `execute-api` | **Push** | `lambda_permission` | None (Invoke allowed from APIGW Service Principal) |
| **SNS** | `:sns:` | **Push** | `lambda_permission` | None (Invoke allowed from SNS Service Principal) |
| **S3** | `arn:aws:s3:::` | **Push** | `lambda_permission` | None (Invoke allowed from S3 Service Principal) |

### 🔐 Extending Permissions

If your function needs to perform additional actions (e.g., writing to an S3 bucket or querying a RDS database), use the `inline_policies` variable.

**Example: Adding S3 Write Access**
```hcl
module "my_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "uploader"
  environment   = "develop"
  
  inline_policies = [
    {
      name   = "S3WriteAccess"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action   = ["s3:PutObject"]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::my-bucket/*"]
        }]
      })
    }
  ]
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
