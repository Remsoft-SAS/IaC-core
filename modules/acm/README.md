# ACM certificates

Creates a DNS-validated ACM certificate and Route 53 validation records.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/acm?ref=main"

  domain_name = "app.example.com"
  environment = "develop"
  zone_id     = "Z0123456789EXAMPLE"
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/acm"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Use a public Route 53 hosted zone you control and delegate it at your registrar before applying. Replace the example zone ID. All SAN validation records are placed in this same zone.
- The certificate is created in the passed AWS provider region. Use us-east-1 for CloudFront and Cognito custom domains; use the API region for Regional API Gateway domains.
- The certificate_arn output waits for DNS validation. DNS delegation or propagation problems can make apply wait until timeout.
- The module allows overwriting validation records. Avoid managing the same record in another Terraform resource. Apex and wildcard SANs can share validation records; review overlapping records in the plan.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_acm_certificate.this`
- `aws_route53_record.validation`
- `aws_acm_certificate_validation.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `domain_name` | Main domain name for the certificate | `string` | — | Yes |
| `subject_alternative_names` | List of additional domains (SANs) | `list(string)` | `[]` | No |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `zone_id` | Route 53 zone ID for DNS validation | `string` | — | Yes |
| `tags` | Additional tags for the resource | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `certificate_arn` | ARN of the validated certificate |
| `certificate_domain` | Primary domain of the certificate |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
