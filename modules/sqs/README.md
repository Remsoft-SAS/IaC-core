# SQS queue

Creates a standard or FIFO queue, optional dead-letter queue, and optional SNS subscription with a queue policy.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sqs?ref=main"

  queue_name                 = "example-jobs"
  environment                = "develop"
  visibility_timeout_seconds = 180
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/sqs"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Queue names append -environment and .fifo for FIFO mode. The DLQ name is queue_name-dlq-environment with the same FIFO suffix. Do not include .fifo in the base name.
- A DLQ is enabled by default with max_receive_count = 5 and 14-day retention. The main queue retains messages for four days by default. Disabling the DLQ returns null DLQ outputs.
- Encryption defaults to alias/aws/sqs. SNS or cross-account delivery to encrypted queues may need a customer-managed KMS key and explicit service/key permissions, which are not created here.
- sns_topic_arn creates an SQS subscription and a source-ARN-restricted queue policy. sns_filter_policy is a JSON string and uses the default message-attribute scope. Raw delivery is not enabled, so SNS messages arrive in an SNS envelope.
- queue_policy is merged with the generated SNS policy. Match queue/topic FIFO compatibility and provide unique deduplication/group IDs where required. high_throughput affects FIFO queues only.
- Set visibility_timeout_seconds for your consumer duration and retries. The module creates no Lambda consumer or alarms.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_sqs_queue.dlq`
- `aws_sqs_queue.this`
- `aws_sns_topic_subscription.this`
- `aws_sqs_queue_policy.this`

Data sources: `aws_iam_policy_document.combined`.

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `queue_name` | Base name of the SQS queue | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `delay_seconds` | Delay time in seconds for message delivery | `number` | `0` | No |
| `max_message_size` | Maximum message size in bytes | `number` | `262144` | No |
| `message_retention_seconds` | Message retention time in seconds | `number` | `345600` | No |
| `receive_wait_time_seconds` | Wait time for receiving messages (Long Polling) | `number` | `10` | No |
| `visibility_timeout_seconds` | Message visibility timeout in seconds | `number` | `30` | No |
| `fifo_queue` | Indicates if the queue is FIFO | `bool` | `false` | No |
| `content_based_deduplication` | Enable content-based deduplication (FIFO only) | `bool` | `false` | No |
| `high_throughput` | Enable high throughput for FIFO queues | `bool` | `false` | No |
| `kms_key_id` | ID or ARN of the KMS key for encryption | `string` | `"alias/aws/sqs"` | No |
| `enable_dlq` | Enable Dead Letter Queue | `bool` | `true` | No |
| `max_receive_count` | Maximum number of times a message is received before being moved to DLQ | `number` | `5` | No |
| `dlq_message_retention_seconds` | Message retention time in DLQ in seconds | `number` | `1209600` | No |
| `sns_topic_arn` | ARN of an SNS topic to subscribe this queue to | `string` | `null` | No |
| `sns_filter_policy` | Filter policy for the SNS subscription (JSON format) | `string` | `null` | No |
| `queue_policy` | Additional queue access policy in JSON format (optional) | `string` | `null` | No |
| `tags` | Additional tags for the resource | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `queue_name` | Final name of the SQS queue |
| `queue_url` | SQS queue URL |
| `queue_arn` | SQS queue ARN |
| `dlq_name` | Dead Letter Queue name (if enabled) |
| `dlq_url` | Dead Letter Queue URL (if enabled) |
| `dlq_arn` | Dead Letter Queue ARN (if enabled) |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
