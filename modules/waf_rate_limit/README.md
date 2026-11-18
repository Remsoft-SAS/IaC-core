# WAF Regional IP rate limit

Creates a Regional WAFv2 Web ACL with one blocking IP rate rule and optional resource associations.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/waf_rate_limit?ref=main"

  name                  = "example-api-rate-limit"
  rate_limit_per_5m     = 10000
  evaluation_window_sec = 300
  resource_arns = [
    "arn:aws:apigateway:us-east-1::/restapis/replace-api-id/stages/develop"
  ]
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/waf_rate_limit"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Replace the stage ARN with an existing Regional REST API stage in the same region as the provider. Use the API Gateway stage ARN format shown, not an execute-api invocation ARN. An empty resource_arns list creates an unattached ACL.
- The default action is allow; the sole rule blocks source IPs exceeding the rate threshold. This is not a managed-rule security ruleset, authentication control, or precise quota.
- Despite its name, rate_limit_per_5m applies to evaluation_window_sec. The module accepts thresholds of at least 100 and windows of 60, 300, 600, or 1200 seconds.
- Aggregation uses the source IP, not a forwarded-IP header. Consider how proxies and NAT affect which users share a limit.
- CloudWatch metrics are enabled; sampled requests are disabled. WAF logging is not configured. Scope is fixed to REGIONAL and cannot protect CloudFront; API Gateway WebSocket APIs are not supported WAF association targets.
- An associated resource can have only one Web ACL. Manage the association in one place.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_wafv2_web_acl.this`
- `aws_wafv2_web_acl_association.this`

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `name` | Name of the Regional Web ACL and its CloudWatch metric | `string` | — | Yes |
| `description` | Description of the Web ACL | `string` | `"Regional IP rate limiting"` | No |
| `rule_name` | Name of the rate-based rule | `string` | `"rate-limit-by-source-ip"` | No |
| `rate_limit_per_5m` | Maximum requests per source IP during the evaluation window | `number` | `10000` | No |
| `evaluation_window_sec` | Rolling rate evaluation window in seconds | `number` | `300` | No |
| `resource_arns` | Regional API Gateway REST stage ARNs to associate with this Web ACL | `list(string)` | `[]` | No |
| `metric_name` | Optional CloudWatch metric name for the rate-based rule | `string` | `null` | No |
| `tags` | Tags applied to the Web ACL | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `web_acl_arn` | ARN of the Regional Web ACL |
| `web_acl_id` | ID of the Regional Web ACL |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
