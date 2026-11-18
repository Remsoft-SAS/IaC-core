# CloudFront distribution

Creates a distribution with a private S3 origin, Origin Access Control, security headers, optional API origin, URL rewriting, and DNS.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cloudfront?ref=main"

  comment               = "example-assets"
  environment           = "develop"
  s3_bucket_domain_name = "your-unique-bucket.s3.us-east-1.amazonaws.com"
  is_spa                = false
  enable_url_rewrite    = false
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/cloudfront"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- The example requires an existing S3 bucket and a bucket policy permitting cloudfront.amazonaws.com to read objects, restricted to this distribution ARN. See the S3 integration below. Use the regional REST bucket domain, not the website endpoint.
- certificate_domain looks up an existing ISSUED certificate using the passed provider; the module does not create a certificate or select a region automatically. Pass an AWS provider configured for us-east-1 when using a custom certificate. The certificate must cover every alias.
- With no aliases or certificate_domain, use the generated cloudfront.net hostname. route53_zone_id creates only an A record for aliases[0]; create additional aliases and AAAA records separately.
- api_gateway_domain_name must contain only a hostname: no protocol, stage, or path. No origin_path or prefix stripping is configured, so the forwarded path must already match the backend. Removing https:// from a stage invoke URL is insufficient.
- SPA mode maps distribution 403/404 responses to /index.html with status 200, which can also mask API errors. URL rewriting appends index.html to static paths. Disable these independently for asset-only distributions.
- enable_waf is declared but unused. web_acl_id accepts an existing CloudFront-scope WAFv2 ACL ARN. The Regional waf_rate_limit module cannot be attached to CloudFront.
- Security response headers apply to the default S3 behavior. API requests are forwarded with zero cache TTL.

## Private S3 integration

This complete pair connects a new bucket to its distribution. Use a globally unique bucket name. Configure your AWS provider in the calling project; with no custom domain this uses the default CloudFront certificate.

```hcl
module "assets" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/s3?ref=main"

  bucket_name                 = "replace-with-your-globally-unique-assets-bucket"
  environment                 = "develop"
  enable_oac_policy           = true
  cloudfront_distribution_arn = module.cdn.distribution_arn
}

module "cdn" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cloudfront?ref=main"

  comment               = "example-assets"
  environment           = "develop"
  s3_bucket_domain_name = module.assets.bucket_regional_domain_name
  is_spa                = false
  enable_url_rewrite    = false
}
```

Terraform resolves the individual bucket/distribution/policy dependencies. Avoid adding module-wide `depends_on` between these two modules, which can introduce a cycle. Upload your static content separately.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_cloudfront_function.url_rewrite`
- `aws_cloudfront_response_headers_policy.security_headers`
- `aws_cloudfront_origin_access_control.s3`
- `aws_cloudfront_distribution.this`
- `aws_route53_record.this`

Data sources: `aws_acm_certificate.issued`.

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `comment` | Descriptive comment for the distribution | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `s3_bucket_domain_name` | Regional domain name of the S3 bucket | `string` | — | Yes |
| `api_gateway_domain_name` | Domain name of the API Gateway (without protocol) | `string` | `null` | No |
| `api_path_pattern` | Path pattern to redirect to API Gateway (e.g. /api/*) | `string` | `"/api/*"` | No |
| `default_root_object` | Default root object | `string` | `"index.html"` | No |
| `price_class` | Price class (PriceClass_100, PriceClass_200, PriceClass_All) | `string` | `"PriceClass_100"` | No |
| `aliases` | List of custom domain names (CNAMEs) | `list(string)` | `[]` | No |
| `certificate_domain` | Domain name to lookup the ACM certificate automatically (must be in us-east-1) | `string` | `null` | No |
| `is_spa` | Enable SPA mode (redirects 403/404 to index.html) | `bool` | `true` | No |
| `enable_url_rewrite` | Enable CloudFront Function for URL rewriting (appends index.html to subfolders) | `bool` | `true` | No |
| `enable_waf` | Unused input; does not create a WAF ACL. | `bool` | `false` | No |
| `web_acl_id` | Existing CloudFront-scope Web ACL ARN. | `string` | `null` | No |
| `route53_zone_id` | Route53 Hosted Zone ID to create an A alias record for the first alias domain. Leave null to skip. | `string` | `null` | No |
| `tags` | Additional tags for the resource | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
| --- | --- |
| `distribution_id` | CloudFront distribution ID |
| `distribution_domain_name` | CloudFront distribution domain name |
| `distribution_hosted_zone_id` | CloudFront distribution hosted zone ID |
| `distribution_arn` | CloudFront distribution ARN |
| `oac_id` | Origin Access Control ID |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.

## License

Copyright 2026 Remsoft SAS. Licensed under the [Apache License, Version 2.0](../../LICENSE). See [NOTICE](../../NOTICE) for attribution.
