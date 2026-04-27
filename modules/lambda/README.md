# 🚀 AWS Lambda Function Module

High-performance Terraform module to manage AWS Lambda functions with integrated IAM roles, dynamic inline policies, and automated event source triggers (SQS, DynamoDB, etc.).

## 🌟 Key Features
- **Auto-Provisioned IAM Role:** Automatically creates a dedicated execution role with basic logging permissions.
- **Smart Event Triggers:** Built-in support for `aws_lambda_event_source_mapping` via `event_source_arn`.
- **Dynamic Inline Policies:** Easily attach multiple custom IAM policies directly to the execution role.
- **VPC Support:** Optional integration with subnets and security groups for private network access.
- **CI/CD Friendly:** Environment variables are smartly merged to prevent Terraform from overwriting manual changes or external deployment updates.
- **CloudWatch Integration:** Automatic log group creation with configurable retention days.

## 📋 Technical Usage

### Basic Function
```hcl
module "my_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "hello-world"
  environment   = "develop"
  handler       = "index.handler"
}
```

### Advanced (SQS Trigger + IAM Permissions)
```hcl
module "sqs_processor" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "sqs-worker"
  environment   = "production"

  # Automatic Event Mapping
  event_source_arn        = "arn:aws:sqs:us-east-1:123456789012:my-queue"
  event_source_batch_size = 5

  # Custom Permissions
  inline_policies = [
    {
      name = "AllowS3Read"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action   = ["s3:GetObject"]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::my-bucket/*"]
        }]
      })
    }
  ]
}
```

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `function_name` | Base name for the Lambda function | `string` | - | **Yes** |
| `environment` | Deployment environment (develop/production) | `string` | - | **Yes** |
| `handler` | Function entry point | `string` | `index.handler` | No |
| `runtime` | Execution runtime | `string` | `nodejs22.x` | No |
| `memory_size` | Allocated memory in MB | `number` | `128` | No |
| `timeout` | Execution timeout in seconds | `number` | `30` | No |
| `event_source_arn` | ARN for event trigger (SQS, DynamoDB, etc.) | `string` | `null` | No |
| `event_source_batch_size` | Number of records per batch | `number` | `1` | No |
| `environment_variables` | Map of env variables | `map(string)` | `{}` | No |
| `inline_policies` | List of IAM inline policies | `list(object)` | `[]` | No |
| `vpc_config` | VPC subnet and security group IDs | `object` | `null` | No |
| `log_retention_days` | CloudWatch log retention period | `number` | `7` | No |
| `tags` | Additional resource tags | `map(string)` | `{}` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `function_name` | Final calculated function name |
| `function_arn` | Amazon Resource Name (ARN) of the function |
| `invoke_arn` | ARN used to invoke the function |
| `role_name` | Name of the IAM execution role |
| `role_arn` | ARN of the IAM execution role |
| `log_group_name` | Name of the CloudWatch Log Group |

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
