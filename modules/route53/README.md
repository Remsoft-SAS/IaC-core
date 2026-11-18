# Route 53 hosted zone and records

Creates a public hosted zone and DNS records, or manages records in an existing zone.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/route53?ref=main"

  domain_name = "example.com"
  environment = "develop"
  records = [{
    name    = "www.example.com"
    type    = "CNAME"
    ttl     = 300
    records = ["example.com"]
  }]
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/route53"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Creating a hosted zone does not register a domain or change registrar delegation. Configure the returned name_servers at your registrar. Use create_zone = false with zone_id to manage an existing zone.
- domain_name and environment remain required when using an existing zone. name_servers is null in this mode.
- Record keys are name_type, so each name/type pair must be unique. Supply records for ordinary records or alias for alias records, never both.
- Alias records need a null TTL, but the current ttl = optional(number, 300) substitutes 300 even when null is supplied. The module therefore cannot currently produce valid alias records. Manage aliases with a separate aws_route53_record resource until this implementation is corrected.
- Creates public zones only; private-zone VPC associations and advanced routing policies are not modeled.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_route53_zone.this`
- `aws_route53_record.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `domain_name` | Domain name | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `create_zone` | Indicates whether to create a new hosted zone | `bool` | `true` | No |
| `zone_id` | Hosted zone ID (if create_zone is false) | `string` | `null` | No |
| `records` | List of records to create | `See schema below` | `[]` | No |
| `tags` | Additional tags for the resource | `map(string)` | `{}` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `records`

```hcl
list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), null)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }), null)
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `zone_id` | Hosted zone ID |
| `name_servers` | List of name servers to configure in the domain registrar |
| `records` | Map of created records |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.
