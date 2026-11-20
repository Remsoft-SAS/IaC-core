# EventBridge buses, rules, targets, and schedules

Creates or references an EventBridge event bus, optional event pattern or cron/rate rules with targets, and optional EventBridge Scheduler schedules. For same-account Lambda schedules, the module creates a narrowly scoped Scheduler execution role when `target_role_arn` is omitted. The caller can still provide an existing role when needed. EventBridge rule target roles remain caller-managed.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/eventbridge?ref=main"

  bus_name    = "example-events"
  environment = "develop"

  rules = {
    order-created = {
      description   = "Process order-created events"
      event_pattern = jsonencode({ source = ["example.orders"] })
      targets = {
        processor = {
          arn      = "arn:aws:lambda:us-east-1:123456789012:function:order-processor"
          role_arn = "arn:aws:iam::123456789012:role/eventbridge-invoke-order-processor"
        }
      }
    }
  }

  schedules = {
    nightly = {
      schedule_expression = "cron(0 2 * * ? *)"
      target_arn   = "arn:aws:lambda:us-east-1:123456789012:function:nightly-job"
      target_input = jsonencode({ source = "eventbridge-scheduler" })
    }
  }
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/eventbridge"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Created bus, rule, and schedule names append `-environment`. When `create = false`, rules are attached to `existing_bus_arn`; this input must be the bus name accepted by the EventBridge rule API. `bus_arn` returns the supplied ARN, while `bus_name` also returns the supplied value because the module does not look up or parse an existing bus.
- `rules` creates EventBridge rules on the selected bus. Set `event_pattern` to match events, `schedule_expression` to a `rate(...)` or `cron(...)` expression, or use both where AWS supports it. `enabled` controls rule state. Rule `targets` is a map keyed by stable target IDs; each target needs an ARN and may have an IAM role ARN and JSON input.
- `schedules` creates independent EventBridge Scheduler schedules, which can invoke supported AWS targets without routing through an event bus. Schedule expressions support `at(...)`, `rate(...)`, and `cron(...)`; `schedule_expression_timezone` defaults to UTC. `state` accepts `ENABLED` or `DISABLED`. For a same-account Lambda ARN, the module creates a role trusted by `scheduler.amazonaws.com` and grants it only `lambda:InvokeFunction` on that ARN. Other target types and cross-account Lambda targets require a caller-supplied role.
- Set `flexible_time_window_mode` to `FLEXIBLE` and provide `flexible_time_window_minutes` to permit delivery within a window; the default `OFF` requests the scheduled time. Optional retry limits and a dead-letter queue ARN are passed to Scheduler.
- The module does not create Lambda targets, Scheduler groups, custom event-bus permissions, archives, or replay. The caller owns those resources and any cross-account/service authorization. Rule target role ARNs remain caller-managed.
- Rule targets attach to the bus created or referenced by this module. Scheduler schedules are regional resources and are separate from EventBridge event-bus rules. Schedules do not accept the custom bus ARN as a destination unless using a supported universal target invocation.
- Use stable map keys: changing a rule, target, or schedule key changes Terraform resource addresses and can replace that configuration. Review plans before changing keys or schedule expressions.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_cloudwatch_event_bus.this`
- `aws_cloudwatch_event_rule.this` (for each entry in `rules`)
- `aws_cloudwatch_event_target.this` (for each target in each rule)
- `aws_scheduler_schedule.this` (for each entry in `schedules`)
- `aws_iam_role.scheduler_lambda` (for same-account Lambda schedules without a supplied role)
- `aws_iam_role_policy.scheduler_lambda_invoke` (scoped to each corresponding Lambda target)

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `bus_name` | Base name of the custom event bus. | `string` | — | Yes |
| `environment` | Deployment environment. | `string` | — | Yes |
| `create` | Create a bus; when false, return existing_bus_arn. | `bool` | `true` | No |
| `existing_bus_arn` | Existing bus ARN used when create is false. | `string` | `""` | No |
| `rules` | EventBridge event rules and targets. | `map(object)` | `{}` | No |
| `schedules` | EventBridge Scheduler schedules and target configuration. | `map(object)` | `{}` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

### `rules` object

Each map value accepts `description` (string, default `""`), `event_pattern` (string, optional JSON), `schedule_expression` (string, optional), `enabled` (bool, default `true`), and `targets` (map, default `{}`). Each target accepts required `arn`, optional `role_arn`, and optional JSON `input`.

Supply at least one of `event_pattern` or `schedule_expression`. Targets are optional. If your target requires an invocation role, provide one and configure its trust and permissions outside this module.

### `schedules` object

Each map value requires `schedule_expression` and `target_arn`. `target_role_arn` is optional for same-account Lambda targets; when omitted, the module creates an execution role scoped to that Lambda and schedule group. Provide it for non-Lambda or cross-account targets. Other optional attributes are `description` (default `""`), `schedule_expression_timezone` (`"UTC"`), `state` (`"ENABLED"`), `start_date`, `end_date`, `flexible_time_window_mode` (`"OFF"`), `flexible_time_window_minutes`, `target_input`, `retry_maximum_event_age`, `retry_maximum_attempts`, `dead_letter_arn`, and `group_name` (`"default"`). Use RFC3339 timestamps for start/end dates. Flexible mode requires `flexible_time_window_minutes`.

## Outputs

| Name | Description |
| --- | --- |
| `bus_name` | Created bus name; existing bus ARN when create is false. |
| `bus_arn` | Created or supplied event bus ARN. |
| `rule_arns` | Map of rule keys to created rule ARNs. |
| `schedule_arns` | Map of schedule keys to created schedule ARNs. |
| `schedule_role_arns` | Map of schedule keys to the generated or caller-supplied execution role ARN. |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
