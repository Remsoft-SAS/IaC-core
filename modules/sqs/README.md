# AWS SQS Module

Module for creating Simple Queue Service (SQS) queues with Dead Letter Queue (DLQ) support.

## Features
- **Auto-DLQ**: Automatically creates a companion Dead Letter Queue for handling failed messages.
- **Redrive Policy**: Configurable max receive count before moving to DLQ.
- **Encryption**: Server-side encryption managed by AWS.

## Inputs
| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `queue_name` | Name of the primary queue | `string` | **Yes** | - |
| `environment` | Deployment environment | `string` | **Yes** | - |
| `visibility_timeout_seconds` | Message visibility timeout | `number` | No | `30` |
| `max_receive_count` | Retries before DLQ | `number` | No | `5` |

## Outputs
| Name | Description |
|---|---|
| `queue_id` | URL of the primary queue |
| `queue_arn` | ARN of the primary queue |
| `dlq_arn` | ARN of the Dead Letter Queue |
