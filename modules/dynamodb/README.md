# AWS DynamoDB Module

Module for DynamoDB tables with PITR, autoscaling, and secondary index support.

## Features
- **Scalability**: Support for PAY_PER_REQUEST or PROVISIONED billing modes.
- **Security**: Points-In-Time Recovery (PITR) enabled.
- **Flexibility**: Define GSI (Global Secondary Indexes) and attributes dynamically.

## Inputs
| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `table_name` | Name of the table | `string` | **Yes** | - |
| `environment` | Deployment environment | `string` | **Yes** | - |
| `hash_key` | Partition key | `string` | **Yes** | - |
| `range_key` | Sort key (optional) | `string` | No | `null` |
| `attributes` | List of attribute definitions | `list` | **Yes** | - |
| `billing_mode` | Billing mode (PAY_PER_REQUEST / PROVISIONED) | `string` | No | `PAY_PER_REQUEST` |

## Outputs
| Name | Description |
|---|---|
| `table_name` | Name of the table |
| `table_arn` | ARN of the table |
| `table_id` | ID of the table |
