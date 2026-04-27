# 📢 AWS SNS Topic Module

Professional Terraform module to manage Amazon Simple Notification Service (SNS) topics with built-in encryption (KMS) and dynamic access policy management.

## 🚀 Key Features
- **Encryption by Default:** Integrated support for AWS KMS encryption (defaults to `alias/aws/sns`).
- **Standard & FIFO Support:** Easily toggle between standard and FIFO topics with name auto-suffixing.
- **Dynamic Access Control:** Automatically manages Topic Policies via `allowed_publishers` variable (supports ARNs and Service Principals).
- **Environment-Aware:** Automatic resource naming following the project-environment pattern.
- **Micro-Infrastructure Ready:** Designed to work as a central hub for fan-out architectures (SNS -> SQS).

## 📋 Technical Usage

### Basic Topic
```hcl
module "notifications" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sns?ref=main"
  topic_name  = "app-events"
  environment = "develop"
}
```

### Advanced (Allowed Publishers + FIFO)
```hcl
module "security_notifications" {
  source      = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sns?ref=main"
  topic_name  = "security-alerts"
  environment = "production"
  
  fifo_topic                  = true
  content_based_deduplication = true

  # Allow specific services to publish
  allowed_publishers = [
    "s3.amazonaws.com",
    "cloudwatch.amazonaws.com",
    "arn:aws:iam::123456789012:role/my-app-role"
  ]
}
```

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `topic_name` | Base name for the SNS topic | `string` | - | **Yes** |
| `environment` | Deployment environment (develop/production) | `string` | - | **Yes** |
| `display_name` | Name displayed in SMS notifications | `string` | `null` | No |
| `fifo_topic` | Enable First-In-First-Out logic | `bool` | `false` | No |
| `content_based_deduplication` | Enable deduplication for FIFO | `bool` | `false` | No |
| `kms_master_key_id` | KMS Key ID for encryption | `string` | `alias/aws/sns` | No |
| `allowed_publishers` | List of IAM ARNs or Service Principals | `list(string)` | `[]` | No |
| `tags` | Additional resource tags | `map(string)` | `{}` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `topic_arn` | Amazon Resource Name (ARN) of the topic |
| `topic_id` | Unique ID of the topic |
| `topic_name` | Final calculated name of the topic |

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
