# EventBridge event bus

Creates a custom event bus or exposes an existing bus ARN without creating resources.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/eventbridge?ref=main"

  bus_name    = "example-events"
  environment = "develop"
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/eventbridge"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Created bus names append -environment. Rules, targets, publisher IAM permissions, cross-account bus policies, archives, and replay are managed separately.
- For reuse set create = false and existing_bus_arn to the existing ARN. bus_name and environment remain required inputs even in this mode.
- When create = false, both bus_name and bus_arn outputs return existing_bus_arn. Consumers requiring a literal name must supply or derive that name separately. No lookup verifies that the existing bus exists.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_cloudwatch_event_bus.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `bus_name` | Base name of the custom event bus. | `string` | — | Yes |
| `environment` | Deployment environment. | `string` | — | Yes |
| `create` | Create a bus; when false, return existing_bus_arn. | `bool` | `true` | No |
| `existing_bus_arn` | Existing bus ARN used when create is false. | `string` | `""` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `bus_name` | Created bus name; existing bus ARN when create is false. |
| `bus_arn` | Created or supplied event bus ARN. |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.
