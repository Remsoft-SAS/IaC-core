# SNS topic

Creates a standard or FIFO topic with KMS encryption and an optional publisher policy.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sns?ref=main"

  topic_name  = "example-events"
  environment = "develop"
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/sns"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Topic names append -environment and add .fifo when fifo_topic is true. Do not add the FIFO suffix yourself. Enable content_based_deduplication only for FIFO topics.
- Encryption defaults to alias/aws/sns. For integrations that need custom KMS permissions, provide a customer-managed key and configure its policy separately.
- allowed_publishers accepts IAM principal ARNs, 12-digit account IDs, and AWS service principal names. A nonempty list creates an sns:Publish policy; it does not create subscriptions.
- The generated publisher policy has no source-account or source-ARN conditions. Manage a more restrictive topic policy externally if your service integration requires them, avoiding competing owners of the same policy.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_sns_topic.this`
- `aws_sns_topic_policy.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `topic_name` | Base name of the SNS topic | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `display_name` | Display name for the SNS topic (used for SMS) | `string` | `null` | No |
| `fifo_topic` | Whether the topic should be FIFO | `bool` | `false` | No |
| `content_based_deduplication` | Enable content-based deduplication (FIFO only) | `bool` | `false` | No |
| `kms_master_key_id` | The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK | `string` | `"alias/aws/sns"` | No |
| `allowed_publishers` | List of ARNs or Service Principals allowed to publish to this topic (e.g. ['s3.amazonaws.com', 'arn:aws:iam::...']) | `list(string)` | `[]` | No |
| `tags` | Additional tags for resources | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `topic_arn` | The ARN of the SNS topic |
| `topic_id` | The ID of the SNS topic |
| `topic_name` | The name of the SNS topic |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
