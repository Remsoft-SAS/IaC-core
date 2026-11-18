# Step Functions state machine

Creates a state machine, execution IAM role, CloudWatch log group, and optional EventBridge trigger.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/step_functions?ref=main"

  name        = "example-workflow"
  environment = "develop"
  type        = "STANDARD"
  definition = jsonencode({
    StartAt = "Done"
    States  = { Done = { Type = "Succeed" } }
  })
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/step_functions"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- State machine names append -environment. The module defaults to EXPRESS; the example explicitly chooses STANDARD. Select the execution model based on workflow duration and delivery semantics.
- definition is an Amazon States Language JSON string. Use jsonencode or templatefile with appropriately encoded substitutions. Provide lambda_arns for Lambda invoke permissions.
- The role includes log delivery and optional Lambda invocation only. Attach additional policies using role_arn (or a separately managed role-policy attachment) for other service integrations. No general additional-policy input is provided.
- Logs default to ERROR with execution data excluded and 14-day retention. A log group is created even when log_level is OFF.
- eventbridge_trigger takes an existing bus name and a JSON event_pattern, then creates the rule, target, and StartExecution role. The bus itself is not created here.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_cloudwatch_log_group.this`
- `aws_iam_role.this`
- `aws_iam_role_policy.invoke_lambdas`
- `aws_iam_role_policy.logs`
- `aws_sfn_state_machine.this`
- `aws_cloudwatch_event_rule.trigger`
- `aws_iam_role.eventbridge`
- `aws_iam_role_policy.eventbridge_start`
- `aws_cloudwatch_event_target.trigger`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `name` | Base state machine name; environment is appended. | `string` | — | Yes |
| `environment` | Deployment environment. | `string` | — | Yes |
| `definition` | Amazon States Language definition as a JSON string. | `string` | — | Yes |
| `type` | State machine type: STANDARD or EXPRESS. | `string` | `"EXPRESS"` | No |
| `lambda_arns` | Lambda ARNs the execution role may invoke. | `list(string)` | `[]` | No |
| `log_level` | Logging level: ALL, ERROR, FATAL, or OFF. | `string` | `"ERROR"` | No |
| `log_include_execution_data` | Include state input/output in logs. | `bool` | `false` | No |
| `log_retention_days` | CloudWatch log retention in days. | `number` | `14` | No |
| `eventbridge_trigger` | Optional EventBridge bus name and JSON event pattern. | `See schema below` | `null` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `eventbridge_trigger`

```hcl
object({
    bus_name      = string
    event_pattern = string
  })
```

## Outputs

| Name | Description |
| --- | --- |
| `state_machine_arn` | State machine ARN. |
| `state_machine_name` | State machine name. |
| `role_arn` | Execution IAM role ARN. |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.
