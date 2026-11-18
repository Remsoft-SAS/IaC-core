# DynamoDB table

Creates a table with optional secondary indexes, TTL, streams, point-in-time recovery, KMS encryption, and regional replicas.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/dynamodb?ref=main"

  table_name  = "example-items"
  environment = "develop"
  hash_key    = "id"
  attributes  = [{ name = "id", type = "S" }]
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/dynamodb"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Table names append -environment. Define attributes only for table/index keys, using S, N, or B; ordinary item fields and TTL fields do not belong in attributes unless they are keys.
- PAY_PER_REQUEST is the default. For PROVISIONED mode supply table capacity and explicit read_capacity/write_capacity on every GSI. Optional GSI capacities default to null and the implementation uses try(), which does not replace null with 5.
- PITR and encryption default to enabled in every environment. Production does not forcibly enable PITR if the caller disables it.
- For TTL, write Unix epoch seconds into the chosen attribute. Streams are disabled by default; enable them before wiring a Lambda stream consumer. Regional replicas require compatible global-table stream settings (NEW_AND_OLD_IMAGES).
- No autoscaling, alarms, or deletion protection are configured. Review key/index replacements and data retention before changing or destroying a table.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_dynamodb_table.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `table_name` | Base name of the DynamoDB table | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `billing_mode` | Billing mode: PROVISIONED or PAY_PER_REQUEST | `string` | `"PAY_PER_REQUEST"` | No |
| `read_capacity` | Read capacity (only if billing_mode is PROVISIONED) | `number` | `5` | No |
| `write_capacity` | Write capacity (only if billing_mode is PROVISIONED) | `number` | `5` | No |
| `hash_key` | Attribute name used as Hash Key | `string` | — | Yes |
| `range_key` | Attribute name used as Range Key (optional) | `string` | `null` | No |
| `attributes` | List of table attributes (required for keys and indexes) | `See schema below` | — | Yes |
| `global_secondary_indexes` | Global Secondary Indexes configuration | `See schema below` | `[]` | No |
| `local_secondary_indexes` | Local Secondary Indexes configuration | `See schema below` | `[]` | No |
| `ttl_attribute` | Attribute name for Time-To-Live (optional) | `string` | `null` | No |
| `enable_point_in_time_recovery` | Enable point-in-time recovery for disaster recovery | `bool` | `true` | No |
| `enable_encryption` | Enable server-side encryption | `bool` | `true` | No |
| `kms_key_arn` | ARN of the KMS key for encryption (optional) | `string` | `null` | No |
| `replica_regions` | Additional regions for global replication | `list(string)` | `[]` | No |
| `enable_streams` | Enable DynamoDB Streams for event-driven flows | `bool` | `false` | No |
| `stream_view_type` | Stream content: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY | `string` | `"NEW_AND_OLD_IMAGES"` | No |
| `tags` | Additional tags for the resource | `map(string)` | `{}` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `attributes`

```hcl
list(object({
    name = string
    type = string
  }))
```

#### `global_secondary_indexes`

```hcl
list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
```

#### `local_secondary_indexes`

```hcl
list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `table_name` | Final name of the DynamoDB table |
| `table_arn` | DynamoDB table ARN |
| `table_id` | DynamoDB table ID |
| `stream_arn` | DynamoDB Stream ARN (if enabled) |
| `stream_label` | DynamoDB Stream label |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
