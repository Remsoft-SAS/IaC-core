# 📊 AWS DynamoDB Table Module (Elite Edition)

Professional Terraform module to manage Amazon DynamoDB tables with support for **Global Secondary Indexes (GSI)**, Time-To-Live (TTL), Point-In-Time Recovery (PITR), and Streams.

## 🌟 Key Features
- **Strict Schema Enforcement:** Uses typed objects for attributes and indexes to prevent misconfigurations.
- **Auto-Protection:** Point-In-Time Recovery (PITR) is enabled by default to ensure disaster recovery capability.
- **Event-Driven Ready:** Easy toggle for DynamoDB Streams to trigger Lambdas on data changes.
- **Hybrid Scaling:** Supports both `PAY_PER_REQUEST` (On-Demand) and `PROVISIONED` billing modes.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `table_name` | Base name for the table. | `string` | - | **Yes** |
| `environment` | develop/production. | `string` | - | **Yes** |
| `hash_key` | Partition key name. | `string` | - | **Yes** |
| `attributes` | List of attributes with types (S, N, B). | `list(obj)` | - | **Yes** |
| `global_secondary_indexes` | GSI configurations. [See Examples](#-gsi-configuration) | `list(obj)` | `[]` | No |
| `enable_streams` | Toggle DynamoDB Streams. | `bool` | `false` | No |
| `ttl_attribute` | Attribute for TTL management. | `string` | `null` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `table_arn` | The ARN of the DynamoDB table. |
| `table_id` | The name (ID) of the table. |
| `stream_arn` | The ARN of the Table Stream (if enabled). |
| `stream_label` | Label for the Stream. |

---

## 🧠 GSI Configuration

When adding indexes, you must also define the index keys in the `attributes` variable.

### Example: Table with GSI
```hcl
module "users_table" {
  source     = "..."
  table_name = "users"
  hash_key   = "userId"

  attributes = [
    { name = "userId", type = "S" },
    { name = "email",  type = "S" } # Used in GSI
  ]

  global_secondary_indexes = [
    {
      name            = "EmailIndex"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
