# 🚀 AWS Lambda Function Module (Ultimate Smart Edition)

Professional Terraform module to manage AWS Lambda functions with **Intelligent Resource Detection**. This module automates the "wiring" between your function and various AWS services, handling both execution models (Pull and Push) seamlessly.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `function_name` | Base name for the Lambda function. | `string` | - | **Yes** |
| `environment` | Deployment environment (develop/production). | `string` | - | **Yes** |
| `event_source_arn` | ARN of the trigger. [See Smart Integration Details](#-smart-event-integration-details) | `string` | `null` | No |
| `event_source_type` | Explicit trigger type (`sqs`, `dynamodb`, `apigateway`, `sns`, `s3`). **Important:** Specify this to avoid "known after apply" errors in count expressions. | `string` | `null` | No |
| `event_source_batch_size` | Number of records per batch (for pull-based sources: SQS, DynamoDB). | `number` | `1` | No |
| `event_source_starting_position` | Starting position for DynamoDB/Kinesis streams: `LATEST` or `TRIM_HORIZON`. Only applies to DynamoDB Streams. | `string` | `null` | No |
| `event_source_filter_pattern` | JSON filter pattern for the event source mapping (e.g., `'{"eventName":["INSERT"]}'`). Leave `null` to disable filtering. | `string` | `null` | No |
| `handler` | Function entry point (e.g., `index.handler`, `app.lambda_handler`). | `string` | `index.handler` | No |
| `runtime` | Execution runtime (e.g., `nodejs22.x`, `python3.12`, `java21`). | `string` | `nodejs22.x` | No |
| `memory_size` | Allocated memory in MB (128–10240). | `number` | `128` | No |
| `timeout` | Execution timeout in seconds (max 900). | `number` | `30` | No |
| `filename` | Path to local `.zip` file for deployment. | `string` | `null` | No |
| `s3_bucket` | S3 bucket containing the function code. | `string` | `null` | No |
| `s3_key` | S3 object key for the function code. | `string` | `null` | No |
| `s3_object_version` | S3 object version ID. | `string` | `null` | No |
| `environment_variables` | Map of environment variables accessible in the function. | `map(string)` | `{}` | No |
| `inline_policies` | Additional IAM inline policies. [See Extending Permissions](#-extending-permissions) | `list(object)` | `[]` | No |
| `vpc_config` | VPC subnet IDs and security group IDs. Enables Lambda to run inside a VPC. | `object` | `null` | No |
| `log_retention_days` | CloudWatch log retention period in days. | `number` | `7` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `function_name` | Final calculated name of the Lambda function (includes environment suffix). |
| `function_arn` | Amazon Resource Name (ARN) of the Lambda function. Use for granting cross-service permissions. |
| `invoke_arn` | Invoke ARN of the Lambda function. Used by API Gateway, SNS, S3, and other services. |
| `role_name` | Name of the IAM execution role created for the function. |
| `role_arn` | ARN of the IAM execution role. |
| `log_group_name` | Name of the CloudWatch Log Group (format: `/aws/lambda/<function_name>`). |
| `log_group_arn` | ARN of the CloudWatch Log Group for log retention/policy management. |

---

## 🚀 Deployment Methods

### Option 1: Local File Deployment

```hcl
module "local_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "my-function"
  environment   = "develop"
  
  filename = "${path.module}/lambda_code.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

### Option 2: S3 Deployment (Recommended for CI/CD)

```hcl
module "s3_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "my-function"
  environment   = "develop"
  
  s3_bucket         = "my-deployment-bucket"
  s3_key            = "lambda-code/my-function-v1.0.0.zip"
  s3_object_version = "abc123def456"  # Optional: track specific versions
  
  handler = "index.handler"
  runtime = "nodejs22.x"
}
```

### Option 3: Default Dummy (For Development/Testing)

If neither `filename` nor `s3_bucket` is provided, the module creates a dummy "Hello World" function.

```hcl
module "dummy_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "my-function"
  environment   = "develop"
  # No filename or s3_bucket specified → uses dummy code
}
```

---

## 🔗 Event Source Examples

### SQS Queue as Trigger

```hcl
module "sqs_consumer" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "sqs-processor"
  environment   = "develop"
  
  event_source_arn  = aws_sqs_queue.my_queue.arn
  event_source_type = "sqs"
  event_source_batch_size = 10
  
  filename = "${path.module}/sqs_handler.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

### DynamoDB Stream as Trigger

```hcl
module "dynamodb_stream_consumer" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "dynamodb-stream-processor"
  environment   = "develop"
  
  event_source_arn              = aws_dynamodb_table.my_table.stream_arn
  event_source_type            = "dynamodb"
  event_source_batch_size       = 100
  event_source_starting_position = "LATEST"  # or "TRIM_HORIZON"
  
  filename = "${path.module}/dynamodb_handler.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

### API Gateway as Trigger

```hcl
module "api_gateway_handler" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "api-handler"
  environment   = "develop"
  
  event_source_arn  = "arn:aws:execute-api:us-east-1:123456789012:abc123/*"
  event_source_type = "apigateway"
  
  filename = "${path.module}/api_handler.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

### SNS Topic as Trigger

```hcl
module "sns_subscriber" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "sns-processor"
  environment   = "develop"
  
  event_source_arn  = aws_sns_topic.my_topic.arn
  event_source_type = "sns"
  
  filename = "${path.module}/sns_handler.zip"
  handler  = "index.handler"
  runtime  = "python3.12"
}
```

### S3 Bucket as Trigger

```hcl
module "s3_trigger_handler" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "s3-processor"
  environment   = "develop"
  
  event_source_arn  = aws_s3_bucket.my_bucket.arn
  event_source_type = "s3"
  
  filename = "${path.module}/s3_handler.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

---

## 🌐 VPC Configuration

To run Lambda functions inside a VPC (for database access, private resources, etc.):

```hcl
module "vpc_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "vpc-function"
  environment   = "develop"
  
  vpc_config = {
    subnet_ids         = ["subnet-12345", "subnet-67890"]
    security_group_ids = ["sg-abcdef"]
  }
  
  filename = "${path.module}/vpc_handler.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

**Note:** The module automatically attaches `AWSLambdaVPCAccessExecutionRole` when VPC is configured.

---

## 🔐 Extending Permissions

Add custom inline policies for additional AWS service access:

```hcl
module "advanced_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "advanced-function"
  environment   = "develop"
  
  event_source_arn  = aws_sqs_queue.my_queue.arn
  event_source_type = "sqs"
  
  inline_policies = [
    {
      name = "S3WriteAccess"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action   = ["s3:PutObject"]
          Effect   = "Allow"
          Resource = ["arn:aws:s3:::my-bucket/*"]
        }]
      })
    },
    {
      name = "DynamoDBAccess"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action   = ["dynamodb:PutItem", "dynamodb:Query"]
          Effect   = "Allow"
          Resource = [aws_dynamodb_table.my_table.arn]
        }]
      })
    }
  ]
  
  filename = "${path.module}/advanced_handler.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

---

## 📊 Environment Variables & CI/CD Integration

```hcl
module "env_lambda" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "env-function"
  environment   = var.environment
  
  environment_variables = {
    LOG_LEVEL           = "DEBUG"
    DATABASE_HOST       = var.db_host
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.users.name
    API_ENDPOINT        = var.api_endpoint
  }
  
  s3_bucket = var.lambda_code_bucket
  s3_key    = "${var.build_id}/lambda-code.zip"
  
  handler = "index.handler"
  runtime = "nodejs22.x"
}
```

**Note:** The module merges environment variables while preserving existing ones, enabling safe CI/CD updates.

---

## 🔍 Event Filtering (Advanced)

Filter events before Lambda execution:

```hcl
module "filtered_dynamodb_stream" {
  source        = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"
  function_name = "stream-processor"
  environment   = "develop"
  
  event_source_arn                = aws_dynamodb_table.users.stream_arn
  event_source_type               = "dynamodb"
  event_source_starting_position  = "LATEST"
  event_source_filter_pattern     = "{\"eventName\":[\"INSERT\",\"MODIFY\"]}"  # Only INSERT/MODIFY
  
  filename = "${path.module}/processor.zip"
  handler  = "index.handler"
  runtime  = "nodejs22.x"
}
```

---

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
