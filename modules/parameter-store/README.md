# SSM Parameter Store

Creates named parameters with Terraform-managed or externally managed values.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/parameter-store?ref=main"

  environment = "develop"
  parameters = [{
    name  = "/example/develop/api-url"
    type  = "String"
    value = "https://api.example.com"
  }]
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/parameter-store"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Parameter names are used verbatim; environment is a tag and is not added to paths. Names must be unique within parameters. Supported AWS types include String, StringList, and SecureString.
- Each object can specify description, key_id, tier, data_type, ignore_value_changes, and tags. KMS key_id is passed only for SecureString; grant callers the appropriate KMS permissions.
- ignore_value_changes creates the initial value and ignores subsequent value updates. Changing this flag moves the parameter between separate Terraform resource addresses, so review the plan and migrate state if preservation is required.
- Values longer than 4096 Terraform characters automatically select Advanced tier. AWS limits are byte-based, so non-ASCII values may require an explicit tier. Advanced parameters incur charges and still have service size limits.
- SecureString values and initial externally managed values remain in Terraform state. The parameters input is not marked sensitive. Keep secrets out of committed files and protect state and plan output.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_ssm_parameter.standard`
- `aws_ssm_parameter.external`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `parameters` | List of parameters to create in Parameter Store | `See schema below` | — | Yes |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `parameters`

```hcl
list(object({
    name                 = string
    value                = string
    type                 = string
    description          = optional(string, "Managed by Terraform")
    key_id               = optional(string, null)
    tier                 = optional(string, "Standard")
    data_type            = optional(string, "text")
    ignore_value_changes = optional(bool, false)
    tags                 = optional(map(string), {})
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `parameters` | Map of created parameters (name => arn) |
| `parameter_names` | List of names of the created parameters |
| `parameter_arns` | List of ARNs of the created parameters |
| `parameter_versions` | Map of created parameters (name => version) |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
