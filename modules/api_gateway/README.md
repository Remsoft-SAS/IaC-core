# API Gateway REST and WebSocket APIs

Creates a Regional REST API with Lambda proxy integrations and optional WebSocket API, domains, DNS, and access logs.

[All modules](../../README.md#modules) · [Setup and provider configuration](../../README.md#requirements)

## Usage

This example is a module block for your own Terraform root configuration. Configure the AWS provider and credentials as described in the root README. Replace example resource identifiers before applying. `ref=main` tracks development; pin a reviewed commit SHA or an existing release tag for reproducibility.

```hcl
module "example" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"

  api_name                  = "example-api"
  environment               = "develop"
  create_lambda_permissions = true
  endpoints = [{
    path                 = "/hello"
    http_method          = "GET"
    lambda_function_name = "hello"
    authorizer_type      = "NONE"
    authorizer_id        = ""
    authorization_scopes = []
  }]
}
```

For a local checkout, replace `source` with `"./IaC-core/modules/api_gateway"` (relative to the calling configuration); omit `?ref=` for local paths.

## Behavior and requirements

- The example requires an existing Lambda named hello-develop in the same account and region. Pass the base name without the environment suffix for REST and WebSocket routes. Use depends_on when creating those functions in the same configuration because integrations construct ARNs from strings.
- Paths support the root ("" or "/") and single segments such as /users. Nested paths such as /users/orders are not expanded into a resource tree. enable_proxy_routes adds /users/{proxy+} and uses the first endpoint for that path as its Lambda and authorization configuration.
- Every endpoint object field is required, including authorizer_id and authorization_scopes. Use authorizer_type = "COGNITO_USER_POOLS" with cognito_user_pool_arns, or "CUSTOM" with an existing authorizer ID. The input comment mentioning COGNITO is not the value used by the implementation.
- CORS creates OPTIONS mock responses; Lambda responses must also return the appropriate CORS headers. Use an explicit origin when allowing credentials. Avoid explicit OPTIONS endpoints when enable_cors is true.
- REST Lambda permissions are opt-in. WebSocket Lambda permissions are created automatically. The module does not create WebSocket authorizers or accept an authorizer ID; JWT is not supported for WebSocket APIs. Use NONE, or AWS_IAM on the supported $connect route.
- Access logs default to disabled. Configure the API Gateway CloudWatch role at account/region level separately before enabling logs. manage_api_gateway_account is declared but unused.
- An empty endpoints list still creates the REST API but no deployment or REST stage. A REST custom domain requires at least one endpoint. Domain certificates must be issued in the API region; route53_zone_id enables alias A records.
- Throttling applies to REST methods. binary_media_types controls binary payload encoding; your Lambda must handle base64 bodies correctly.

## Resources

Resources below are declared by this module; optional resources are created only when their feature is enabled.

- `aws_api_gateway_rest_api.this`
- `aws_api_gateway_authorizer.cognito`
- `aws_api_gateway_resource.endpoints`
- `aws_api_gateway_method.endpoints`
- `aws_api_gateway_integration.lambda`
- `aws_api_gateway_method.options`
- `aws_api_gateway_integration.options`
- `aws_api_gateway_method_response.options`
- `aws_api_gateway_integration_response.options`
- `aws_api_gateway_resource.proxy`
- `aws_api_gateway_method.proxy`
- `aws_api_gateway_integration.proxy`
- `aws_api_gateway_method.proxy_options`
- `aws_api_gateway_integration.proxy_options`
- `aws_api_gateway_method_response.proxy_options`
- `aws_api_gateway_integration_response.proxy_options`
- `aws_api_gateway_deployment.this`
- `aws_api_gateway_stage.this`
- `aws_api_gateway_method_settings.all`
- `aws_cloudwatch_log_group.api_gateway`
- `aws_apigatewayv2_api.websocket`
- `aws_apigatewayv2_integration.websocket`
- `aws_apigatewayv2_route.websocket`
- `aws_apigatewayv2_stage.websocket`
- `aws_cloudwatch_log_group.websocket`
- `aws_lambda_permission.rest`
- `aws_lambda_permission.websocket`
- `aws_api_gateway_domain_name.this`
- `aws_api_gateway_base_path_mapping.this`
- `aws_apigatewayv2_domain_name.websocket`
- `aws_apigatewayv2_api_mapping.websocket`
- `aws_route53_record.custom_domain`
- `aws_route53_record.websocket_custom_domain`

Data sources: `aws_caller_identity.current`, `aws_region.current`.

## Inputs

Required means no Terraform default is declared. Optional inputs may still be required when enabling a feature. Types and defaults below match the source; `null` means unset.

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `api_name` | Name of the REST API | `string` | — | Yes |
| `environment` | Target environment (develop/production) | `string` | — | Yes |
| `endpoints` | REST route definitions; all object fields are required. See behavior notes. | `See schema below` | — | Yes |
| `cognito_user_pool_arns` | List of Cognito User Pool ARNs for the authorizer | `list(string)` | `[]` | No |
| `enable_cors` | Enable CORS for all endpoints | `bool` | `true` | No |
| `cors_allow_origin` | Value for Access-Control-Allow-Origin header | `string` | `"*"` | No |
| `cors_allow_credentials` | Value for Access-Control-Allow-Credentials header | `bool` | `false` | No |
| `cors_allow_headers` | Additional headers to include in Access-Control-Allow-Headers (comma-separated) | `string` | `""` | No |
| `enable_access_logs` | Enable CloudWatch Access Logs. Requires a CloudWatch Logs role ARN configured at account level (aws_api_gateway_account). Defaults to false to avoid deployment errors on accounts without it. | `bool` | `false` | No |
| `access_log_format` | Custom format for access logs | `string` | `"{ \"requestId\":\"$context.requestId\", \"ip\":\"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\", \"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\", \"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"` | No |
| `log_retention_days` | Log retention in days | `number` | `7` | No |
| `manage_api_gateway_account` | Unused input; configure the account logging role externally. | `bool` | `false` | No |
| `throttling_burst_limit` | Maximum burst limit for throttling | `number` | `500` | No |
| `throttling_rate_limit` | Maximum rate limit for throttling | `number` | `1000` | No |
| `tags` | Additional tags for the resources | `map(string)` | `{}` | No |
| `enable_proxy_routes` | Automatically create a {proxy+} child resource for each endpoint path, enabling sub-route handling (e.g. /users/{proxy+}). Default false for backwards compatibility. | `bool` | `false` | No |
| `enable_websocket` | Enable a WebSocket API (API Gateway V2) alongside the REST API | `bool` | `false` | No |
| `websocket_api_name` | Name override for the WebSocket API. Defaults to '<api_name>-websocket-<environment>' | `string` | `""` | No |
| `websocket_route_selection_expression` | Route selection expression for the WebSocket API | `string` | `"$request.body.action"` | No |
| `websocket_routes` | WebSocket route definitions. See authorization limitations above. | `See schema below` | `[]` | No |
| `websocket_enable_access_logs` | Enable CloudWatch access logs for the WebSocket API. Requires a CloudWatch Logs role ARN configured at account level (aws_api_gateway_account). Defaults to false to avoid deployment errors on accounts without it. | `bool` | `false` | No |
| `websocket_access_log_format` | Log format for WebSocket API access logs (used only if websocket_enable_access_logs = true) | `string` | `"{ \"requestId\":\"$context.requestId\", \"connectionId\":\"$context.connectionId\", \"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\", \"integrationError\":\"$context.integrationErrorMessage\" }"` | No |
| `custom_domain_name` | Custom domain name for the REST API (e.g. api.example.com). Leave empty to skip. | `string` | `""` | No |
| `custom_domain_certificate_arn` | ACM certificate ARN for the REST API custom domain (must be in the same region) | `string` | `""` | No |
| `custom_domain_base_path` | Base path mapping for the REST API custom domain. Empty string maps to the root path. | `string` | `""` | No |
| `websocket_custom_domain_name` | Custom domain name for the WebSocket API (e.g. ws.example.com). Leave empty to skip. | `string` | `""` | No |
| `websocket_custom_domain_certificate_arn` | ACM certificate ARN for the WebSocket custom domain (must be in the same region) | `string` | `""` | No |
| `route53_zone_id` | Route53 hosted zone ID. When provided, the module creates alias A records for the REST and/or WebSocket custom domains automatically. | `string` | `""` | No |
| `create_lambda_permissions` | Auto-create Lambda invoke permissions for REST API endpoints. When true, the module creates one aws_lambda_permission per unique lambda_function_name. Set to false (default) when managing permissions externally. | `bool` | `false` | No |
| `binary_media_types` | List of binary media types for API Gateway to base64-encode (e.g. multipart/form-data for file uploads) | `list(string)` | `[]` | No |

### Object schemas

Attributes without `optional(...)` must be provided, even when their names or comments suggest otherwise.

#### `endpoints`

```hcl
list(object({
    path                 = string
    http_method          = string
    lambda_function_name = string
    authorizer_type      = string
    authorizer_id        = string
    authorization_scopes = list(string)
  }))
```

#### `websocket_routes`

```hcl
list(object({
    route_key            = string
    lambda_function_name = string
    authorization_type   = string
  }))
```

## Outputs

| Name | Description |
| --- | --- |
| `api_id` | API Gateway ID |
| `api_arn` | API Gateway ARN |
| `execution_arn` | API Gateway execution ARN |
| `invoke_url` | Base URL to invoke the API (null if no endpoints are defined) |
| `stage_name` | API stage name (null if no endpoints are defined) |
| `websocket_api_id` | WebSocket API ID (null if enable_websocket = false) |
| `websocket_api_endpoint` | WebSocket endpoint URL — wss://... (null if enable_websocket = false) |
| `websocket_execution_arn` | Execution ARN for granting Lambda invoke permissions (null if enable_websocket = false) |
| `custom_domain_regional_domain_name` | Regional domain name to use as DNS CNAME/ALIAS target for the REST API custom domain (null if not configured) |
| `custom_domain_hosted_zone_id` | Hosted zone ID for the REST API custom domain — use with Route53 alias records (null if not configured) |
| `custom_domain_target` | Regional domain name of the REST API custom domain (used as Route53 alias name — null if not configured) |
| `stage_invoke_url` | Direct invoke URL of the deployed stage (null if no endpoints are defined) |
| `websocket_custom_domain_target` | Target domain name to use as DNS CNAME/ALIAS for the WebSocket custom domain (null if not configured) |
| `websocket_custom_domain_hosted_zone_id` | Hosted zone ID for the WebSocket custom domain — use with Route53 alias records (null if not configured) |

## Source and maintenance

See [main.tf](./main.tf) for resource behavior, [variables.tf](./variables.tf) for the input contract, and [outputs.tf](./outputs.tf) for returned values. Review `terraform plan` in your calling configuration before applying upgrades. See the [contribution guide](../../CONTRIBUTING.md) for repository conventions.
