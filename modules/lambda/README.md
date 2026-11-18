# Lambda function

Creates a ZIP-based Lambda function, execution role, log group, optional VPC attachment, and event-source permissions or mappings.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"

  function_name = "example-handler"
  environment   = "develop"
  filename      = "${path.module}/function.zip"
  runtime       = "nodejs22.x"
  handler       = "index.handler"
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/lambda"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Build function.zip before planning. Choose a local filename OR an S3 bucket/key, not both. The module does not build application code or support container images. With neither source it generates a Node.js index.handler Hello World ZIP; keep the default runtime/handler for that fallback.
- Names append -environment. The function ignores changes to filename, s3_key, s3_object_version, source_code_hash, and environment. Deploy subsequent application code through your deployment pipeline; changing these Terraform inputs alone will not update code.
- Nonempty environment_variables invokes a local-exec AWS CLI + jq merge. Install both tools on the machine running Terraform and configure CLI credentials and region to match the Terraform provider; provider aliases and assume-role settings are not inherited by the CLI. The caller needs lambda:GetFunctionConfiguration and lambda:UpdateFunctionConfiguration.
- The merge preserves keys omitted from the input; removing a key does not delete it remotely. Values are interpolated into a shell command, so avoid shell-sensitive or untrusted values and manage such environment updates through a controlled deployment process.
- Set event_source_type explicitly when an ARN is unknown until apply. Supported types are sqs, dynamodb, apigateway, sns, and s3. Only one event source is modeled by the inputs.
- SQS and DynamoDB create event source mappings and read permissions. DynamoDB requires a stream ARN and starting position (LATEST or TRIM_HORIZON). For SQS, size visibility timeout for the handler and add KMS decrypt access when required; partial batch failure reporting is not configured.
- API Gateway, SNS, and S3 create invoke permissions only. Configure the API integration, SNS subscription, or S3 notification separately.
- VPC configuration attaches the managed VPC execution policy but creates no network resources. Supply subnets/security groups and outbound connectivity as required. inline_policies accepts unique names with JSON policy strings; layer_arns accepts versioned layer ARNs.

Providers: `hashicorp/aws`, `hashicorp/archive` (fallback ZIP), and `hashicorp/null` (environment merge). Other modules use `hashicorp/aws`. See the root README for version guidance.

## SQS consumer

Build `consumer.zip` with your handler before running Terraform. This example connects a queue to one Lambda event source mapping. Configure AWS, archive, and null providers in the caller as described in the root README.

```hcl
module "jobs" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sqs?ref=main"

  queue_name                 = "example-jobs"
  environment                = "develop"
  visibility_timeout_seconds = 180
}

module "consumer" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/lambda?ref=main"

  function_name     = "example-consumer"
  environment       = "develop"
  filename          = "${path.module}/consumer.zip"
  timeout           = 30
  event_source_type = "sqs"
  event_source_arn  = module.jobs.queue_arn
}
```

For a customer-managed queue KMS key, grant the consumer role `kms:Decrypt` through `inline_policies` and the key policy as appropriate.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_iam_role.this`
- `aws_iam_role_policy_attachment.basic`
- `aws_iam_role_policy.sqs_consumer`
- `aws_iam_role_policy.dynamodb_consumer`
- `aws_iam_role_policy_attachment.vpc`
- `aws_iam_role_policy.inline`
- `aws_lambda_function.this`
- `aws_lambda_event_source_mapping.this`
- `aws_lambda_permission.this`
- `aws_cloudwatch_log_group.this`
- `null_resource.env_vars_merge`

Data sources: `archive_file.dummy`.

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `function_name` | Base name of the Lambda function | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `handler` | Function handler (e.g., index.handler) | `string` | `"index.handler"` | No |
| `runtime` | Execution runtime (e.g., nodejs22.x) | `string` | `"nodejs22.x"` | No |
| `memory_size` | Allocated memory in MB | `number` | `128` | No |
| `timeout` | Maximum execution time in seconds | `number` | `30` | No |
| `filename` | Path to local .zip file (for local deployments) | `string` | `null` | No |
| `s3_bucket` | S3 bucket where the code is located | `string` | `null` | No |
| `s3_key` | S3 key for the code | `string` | `null` | No |
| `s3_object_version` | S3 object version | `string` | `null` | No |
| `vpc_config` | VPC configuration (subnet_ids and security_group_ids) | `See schema below` | `null` | No |
| `environment_variables` | Environment variables for the function | `map(string)` | `{}` | No |
| `inline_policies` | List of additional inline policies {name, policy} | `See schema below` | `[]` | No |
| `event_source_arn` | ARN of the event source (SQS, DynamoDB Stream, etc.) | `string` | `null` | No |
| `event_source_type` | Type of event source (sqs, dynamodb, apigateway, sns, s3). Used to avoid 'known after apply' errors in count. | `string` | `null` | No |
| `event_source_batch_size` | The largest number of records that Lambda will retrieve from your event source at the time of invoking your function | `number` | `1` | No |
| `event_source_starting_position` | Starting position for DynamoDB/Kinesis streams (LATEST or TRIM_HORIZON). Only applies when event_source_type is dynamodb. | `string` | `null` | No |
| `event_source_filter_pattern` | JSON filter pattern for the event source mapping (e.g. '{"eventName":["INSERT"]}'). Leave null to disable filtering. | `string` | `null` | No |
| `layer_arns` | List of Lambda Layer ARNs to attach to the function (max 5) | `list(string)` | `[]` | No |
| `log_retention_days` | Log retention days in CloudWatch | `number` | `7` | No |
| `tags` | Additional tags for resources | `map(string)` | `{}` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `vpc_config`

```hcl
object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
```

#### `inline_policies`

```hcl
list(object({
    name   = string
    policy = string
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `function_name` | Final name of the Lambda function |
| `function_arn` | ARN of the Lambda function |
| `invoke_arn` | Invoke ARN of the Lambda function |
| `role_name` | Name of the IAM execution role |
| `role_arn` | ARN of the IAM execution role |
| `log_group_name` | Name of the CloudWatch Log Group |
| `log_group_arn` | ARN of the CloudWatch Log Group |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.
