# Cognito user pool

Creates a user pool and app client with password policies, TOTP MFA, Lambda triggers, optional social providers, and a custom domain.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/cognito?ref=main"

  pool_name         = "example-users"
  environment       = "develop"
  mfa_configuration = "OPTIONAL"
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/cognito"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- Creates a user pool and app client, not a Cognito identity pool. MFA uses software tokens; SMS MFA configuration is not provided.
- User pools in environment = "production" have deletion protection enabled. Schema changes are ignored after creation; plan attribute design before deploying.
- For each supported Lambda permission, provide both its ARN and enable flag. Trigger ARNs configure the pool independently of these flags. Custom challenge authentication generally needs define, create, and verify handlers; handler code is supplied by the caller.
- enable_post_confirmation is declared but unused. lambda_post_confirmation_arn wires the trigger, but its invoke permission must be managed externally. The pre-signup and custom-challenge permissions are not scoped to the pool ARN; review them for your deployment.
- custom_domain requires domain_name and an existing public hosted zone. The parent domain must resolve as required by Cognito. The ACM lookup uses the same provider as the pool, while Cognito custom-domain certificates must be in us-east-1. This implementation does not support a separate certificate provider; use a us-east-1 pool for this integrated path or manage the domain externally.
- The certificate lookup matches domain_name (or an inferred parent), not necessarily the custom hostname. Ensure the selected certificate is issued and covers the custom domain; the lookup also permits PENDING_VALIDATION, which is not ready for domain creation.
- Google, Microsoft OIDC, and Facebook are enabled by nonempty client IDs and require valid provider credentials. callback_urls enables the OAuth authorization-code flow; register matching redirect URLs with your identity providers. No default hosted-domain prefix is created.
- Social client secrets are marked sensitive, but remain in Terraform state. Protect the backend and inject credentials outside committed configuration.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_cognito_user_pool.this`
- `aws_cognito_user_pool_domain.custom`
- `aws_route53_record.auth_alias`
- `aws_cognito_identity_provider.google`
- `aws_cognito_identity_provider.microsoft`
- `aws_cognito_identity_provider.facebook`
- `aws_cognito_user_pool_client.this`
- `aws_lambda_permission.pre_signup`
- `aws_lambda_permission.define_auth`
- `aws_lambda_permission.create_auth`
- `aws_lambda_permission.verify_auth`
- `aws_lambda_permission.migration`

Data sources: `aws_route53_zone.selected`, `aws_acm_certificate.wildcard`.

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `pool_name` | Base name for the User Pool | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `username_attributes` | Attributes used for login (email, phone_number) | `list(string)` | `["email"]` | No |
| `custom_attributes` | List of custom attributes to add to the schema | `See schema below` | `[]` | No |
| `password_minimum_length` | Password minimum length. | `number` | `8` | No |
| `password_require_lowercase` | Password require lowercase. | `bool` | `true` | No |
| `password_require_numbers` | Password require numbers. | `bool` | `true` | No |
| `password_require_symbols` | Password require symbols. | `bool` | `true` | No |
| `password_require_uppercase` | Password require uppercase. | `bool` | `true` | No |
| `temp_password_validity_days` | Temp password validity days. | `number` | `7` | No |
| `mfa_configuration` | MFA configuration (OFF, ON, OPTIONAL) | `string` | `"OFF"` | No |
| `advanced_security_mode` | Advanced security mode (OFF, AUDIT, ENFORCED) | `string` | `"OFF"` | No |
| `lambda_pre_signup_arn` | Lambda pre signup arn. | `string` | `null` | No |
| `lambda_define_auth_arn` | Lambda define auth arn. | `string` | `null` | No |
| `lambda_create_auth_arn` | Lambda create auth arn. | `string` | `null` | No |
| `lambda_verify_auth_arn` | Lambda verify auth arn. | `string` | `null` | No |
| `lambda_post_confirmation_arn` | Lambda post confirmation arn. | `string` | `null` | No |
| `lambda_user_migration_arn` | ARN for User Migration trigger | `string` | `null` | No |
| `enable_pre_signup` | Enable pre signup. | `bool` | `false` | No |
| `enable_define_auth` | Enable define auth. | `bool` | `false` | No |
| `enable_create_auth` | Enable create auth. | `bool` | `false` | No |
| `enable_verify_auth` | Enable verify auth. | `bool` | `false` | No |
| `enable_migration` | Enable migration. | `bool` | `false` | No |
| `enable_post_confirmation` | Unused input; manage post-confirmation invoke permission externally. | `bool` | `false` | No |
| `domain_name` | Root domain for Route 53 and ACM, for example example.com. | `string` | `""` | No |
| `custom_domain` | Custom authentication domain, for example auth.example.com. | `string` | `""` | No |
| `google_client_id` | Google client id. | `string` | `""` | No |
| `google_client_secret` | Google client secret. Sensitive. | `string` | `""` | No |
| `microsoft_client_id` | Microsoft client id. | `string` | `""` | No |
| `microsoft_client_secret` | Microsoft client secret. Sensitive. | `string` | `""` | No |
| `microsoft_tenant_id` | Microsoft tenant id. | `string` | `"common"` | No |
| `facebook_client_id` | Facebook client id. | `string` | `""` | No |
| `facebook_client_secret` | Facebook client secret. Sensitive. | `string` | `""` | No |
| `callback_urls` | Callback urls. | `list(string)` | `[]` | No |
| `logout_urls` | Logout urls. | `list(string)` | `[]` | No |
| `access_token_validity_hours` | Access token validity hours. | `number` | `1` | No |
| `id_token_validity_hours` | Id token validity hours. | `number` | `1` | No |
| `refresh_token_validity_days` | Refresh token validity days. | `number` | `30` | No |
| `explicit_auth_flows` | Explicit auth flows for the app client | `list(string)` | `["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]` | No |
| `prevent_user_existence_errors` | If true, Cognito returns a generic error for non-existent users. If false, it returns UserNotFoundException. | `bool` | `true` | No |
| `tags` | Tags. | `map(string)` | `{}` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `custom_attributes`

```hcl
list(object({
    name                = string
    attribute_data_type = string
    mutable             = bool
    required            = bool
    string_attribute_constraints = optional(object({
      min_length = number
      max_length = number
    }))
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `user_pool_id` | Cognito User Pool ID |
| `user_pool_arn` | Cognito User Pool ARN |
| `user_pool_endpoint` | Cognito User Pool endpoint |
| `user_pool_client_id` | Cognito User Pool Client ID |
| `user_pool_client_secret` | Cognito User Pool Client Secret (if applicable) Sensitive. |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.
