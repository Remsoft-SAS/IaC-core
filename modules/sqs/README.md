# 📥 AWS SQS Queue Module

Highly configurable Terraform module to manage Amazon SQS queues with built-in support for FIFO, Dead Letter Queues (DLQ), KMS Encryption, and seamless SNS Integration.

## 🌟 Key Features
- **Automated DLQ:** Automatically creates and links a Dead Letter Queue with configurable retry attempts.
- **SNS Fan-out Integration:** built-in support for `aws_sns_topic_subscription` and automated IAM policy management when providing an `sns_topic_arn`.
- **FIFO Support:** Easy toggle for FIFO queues with high-throughput options.
- **Secure by Default:** Integrated KMS encryption (defaults to `alias/aws/sqs`).
- **Dynamic Policies:** Automatically combines custom IAM policies with service-specific permissions (like SNS).

## 📋 Technical Usage

### Basic Queue
```hcl
module "my_queue" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sqs?ref=main"
  queue_name  = "orders"
  environment = "develop"
}
```

### Advanced (SNS Subscription + Filter Policy)
```hcl
module "whatsapp_notifications" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sqs?ref=main"
  queue_name  = "whatsapp-notifications"
  environment = "production"

  # Automatic SNS Integration
  sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
  sns_filter_policy = jsonencode({
    type = ["whatsapp"]
  })

  enable_dlq        = true
  max_receive_count = 3
}
```

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `queue_name` | Base name for the SQS queue | `string` | - | **Yes** |
| `environment` | Deployment environment (develop/production) | `string` | - | **Yes** |
| `sns_topic_arn` | ARN of an SNS topic to subscribe to | `string` | `null` | No |
| `sns_filter_policy` | Filter policy for SNS (JSON) | `string` | `null` | No |
| `fifo_queue` | Enable First-In-First-Out logic | `bool` | `false` | No |
| `visibility_timeout_seconds` | Message visibility timeout | `number` | `30` | No |
| `enable_dlq` | Create a companion DLQ | `bool` | `true` | No |
| `max_receive_count` | Retries before moving to DLQ | `number` | `5` | No |
| `kms_key_id` | KMS Key for encryption | `string` | `alias/aws/sqs` | No |
| `queue_policy` | Additional custom IAM policy (JSON) | `string` | `null` | No |
| `tags` | Additional resource tags | `map(string)` | `{}` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `queue_arn` | Amazon Resource Name (ARN) of the main queue |
| `queue_url` | URL of the main queue |
| `dlq_arn` | ARN of the Dead Letter Queue (if enabled) |
| `dlq_url` | URL of the Dead Letter Queue (if enabled) |

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
