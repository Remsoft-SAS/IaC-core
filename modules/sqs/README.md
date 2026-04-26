# SQS Module

Generic module to manage AWS SQS queues with support for FIFO, Dead Letter Queues (DLQ), and encryption.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `queue_name` | Base name of the SQS queue | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `fifo_queue` | Indicates if the queue is FIFO | `boolean` | No | `false` |
| `visibility_timeout_seconds` | Message visibility timeout in seconds | `number` | No | `30` |
| `message_retention_seconds` | Message retention time in seconds | `number` | No | `345600` (4 days) |
| `receive_wait_time_seconds` | Wait time for receiving messages (Long Polling) | `number` | No | `10` |
| `enable_dlq` | Enable Dead Letter Queue | `boolean` | No | `true` |
| `max_receive_count` | Max receive count before moving to DLQ | `number` | No | `5` |
| `kms_key_id` | KMS key for encryption | `string` | No | `"alias/aws/sqs"` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `queue_name` | Final name of the SQS queue |
| `queue_url` | SQS queue URL |
| `queue_arn` | SQS queue ARN |
| `dlq_url` | DLQ URL (if enabled) |

## 📝 Usage Example

```hcl
module "notifications" {
  source = "../../modules/sqs"

  queue_name  = "order-notifications"
  environment = "develop"
  fifo_queue  = true
}
```
