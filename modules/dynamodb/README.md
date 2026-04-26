# DynamoDB Module

Generic module to manage AWS DynamoDB tables with support for GSIs, LSIs, TTL, and Streams.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `table_name` | Base name of the DynamoDB table | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `hash_key` | Attribute name used as Hash Key | `string` | **Yes** | - |
| `attributes` | List of table attributes (name and type) | `list(object)` | **Yes** | - |
| `range_key` | Attribute name used as Range Key | `string` | No | `null` |
| `billing_mode` | Billing mode: `PROVISIONED` or `PAY_PER_REQUEST` | `string` | No | `"PAY_PER_REQUEST"` |
| `read_capacity` | Read capacity (if `PROVISIONED`) | `number` | No | `5` |
| `write_capacity` | Write capacity (if `PROVISIONED`) | `number` | No | `5` |
| `global_secondary_indexes` | GSI configuration | `any` | No | `[]` |
| `enable_streams` | Enable DynamoDB Streams | `boolean` | No | `false` |
| `ttl_attribute` | Attribute name for TTL | `string` | No | `null` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `table_name` | Final name of the DynamoDB table |
| `table_arn` | DynamoDB table ARN |
| `table_id` | DynamoDB table ID |
| `stream_arn` | DynamoDB Stream ARN (if enabled) |

## 📝 Usage Example

```hcl
module "table" {
  source = "../../modules/dynamodb"

  table_name  = "rempays-orders"
  environment = "production"
  hash_key    = "orderId"
  
  attributes = [
    { name = "orderId", type = "S" },
    { name = "userId", type = "S" }
  ]
}
```
