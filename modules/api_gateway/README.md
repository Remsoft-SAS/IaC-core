# AWS API Gateway Module

Terraform module to manage Amazon API Gateway with **Integrated Security**. It automates endpoint creation, Lambda integrations, CORS management, Cognito/Lambda Authorizers, and optionally a **WebSocket API** (API Gateway V2).

## Inputs

### REST API

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `api_name` | Base name for the REST API. | `string` | - | **Yes** |
| `environment` | Target environment (develop/production). | `string` | - | **Yes** |
| `endpoints` | List of paths and methods. See [Endpoint Configuration](#endpoint-configuration). | `list(obj)` | - | **Yes** |
| `cognito_user_pool_arns` | Cognito User Pool ARNs for the authorizer. | `list(string)` | `[]` | No |
| `enable_cors` | Global CORS toggle. | `bool` | `true` | No |
| `cors_allow_origin` | Value for `Access-Control-Allow-Origin`. | `string` | `"*"` | No |
| `cors_allow_credentials` | Value for `Access-Control-Allow-Credentials`. | `bool` | `false` | No |
| `enable_proxy_routes` | Auto-create `{proxy+}` child resource per endpoint path (e.g. `/users/{proxy+}`) with `ANY` method + CORS. | `bool` | `false` | No |
| `throttling_burst_limit` | Maximum burst limit for throttling. | `number` | `500` | No |
| `throttling_rate_limit` | Requests per second limit. | `number` | `1000` | No |
| `enable_access_logs` | CloudWatch access logs toggle. Requires CloudWatch Logs role ARN configured at account level. | `bool` | `false` | No |
| `log_retention_days` | Log retention in days. | `number` | `7` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

### WebSocket API (API Gateway V2)

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `enable_websocket` | Enable a WebSocket API alongside the REST API. | `bool` | `false` | No |
| `websocket_routes` | List of WebSocket routes. See [WebSocket Routes](#websocket-route-configuration). | `list(obj)` | `[]` | No |
| `websocket_api_name` | Name override for the WebSocket API. | `string` | `"<api_name>-websocket-<env>"` | No |
| `websocket_route_selection_expression` | Expression used to select the route. | `string` | `"$request.body.action"` | No |
| `websocket_access_log_format` | Log format for WebSocket access logs. | `string` | JSON preset | No |

### Custom Domain — REST API

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `custom_domain_name` | Custom domain for the REST API (e.g. `api.example.com`). Leave empty to skip. | `string` | `""` | No |
| `custom_domain_certificate_arn` | ACM certificate ARN for the REST API domain (same region). | `string` | `""` | No |
| `custom_domain_base_path` | Base path mapping. Empty string maps to the root. | `string` | `""` | No |

### Custom Domain — WebSocket API

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `websocket_custom_domain_name` | Custom domain for the WebSocket API (e.g. `ws.example.com`). Leave empty to skip. | `string` | `""` | No |
| `websocket_custom_domain_certificate_arn` | ACM certificate ARN for the WebSocket domain (same region). | `string` | `""` | No |

## Outputs

### REST API

| Name | Description |
| :--- | :--- |
| `api_id` | The ID of the REST API. |
| `api_arn` | The ARN of the REST API. |
| `invoke_url` | Base URL to invoke the REST API (`null` if no endpoints). |
| `stage_invoke_url` | Direct invoke URL of the deployed stage (`null` if no endpoints). |
| `execution_arn` | Execution ARN for Lambda permissions. |
| `stage_name` | Deployed stage name (`null` if no endpoints). |

### WebSocket API

| Name | Description |
| :--- | :--- |
| `websocket_api_id` | WebSocket API ID (`null` if disabled). |
| `websocket_api_endpoint` | WebSocket endpoint `wss://...` (`null` if disabled). |
| `websocket_execution_arn` | Execution ARN for granting Lambda invoke permissions (`null` if disabled). |

### Custom Domains

| Name | Description |
| :--- | :--- |
| `custom_domain_target` | Regional domain name for REST API custom domain — Route53 alias target (`null` if not configured). |
| `custom_domain_regional_domain_name` | Same as `custom_domain_target` (legacy name). |
| `custom_domain_hosted_zone_id` | Hosted zone ID for REST API Route53 alias record (`null` if not configured). |
| `websocket_custom_domain_target` | CNAME/ALIAS target for WebSocket custom domain DNS record (`null` if not configured). |
| `websocket_custom_domain_hosted_zone_id` | Hosted zone ID for WebSocket Route53 alias record (`null` if not configured). |

---

## Endpoint Configuration

Each entry in the `endpoints` list supports:

| Attribute | Description | Options |
| :--- | :--- | :--- |
| `path` | Resource path (e.g., `/users`). | String |
| `http_method` | HTTP verb (GET, POST, etc.). | String |
| `lambda_function_name` | Lambda function name (without environment suffix). | String |
| `authorizer_type` | Security model. | `NONE`, `COGNITO`, `CUSTOM` |
| `authorizer_id` | Required if type is `CUSTOM`. | String |
| `authorization_scopes` | OAuth Scopes for Cognito. | `list(string)` |

---

## WebSocket Route Configuration

Each entry in the `websocket_routes` list supports:

| Attribute | Description | Options |
| :--- | :--- | :--- |
| `route_key` | WebSocket route key. | `$connect`, `$disconnect`, `$default`, or any custom action name |
| `lambda_function_name` | Lambda function name (without environment suffix). | String |
| `authorization_type` | Authorization for this route. | `NONE`, `AWS_IAM`, `CUSTOM`, `JWT` |

---

## Examples

### REST API — Secure & Public Endpoints

```hcl
module "my_api" {
  source   = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  api_name = "gateway"

  cognito_user_pool_arns = ["arn:aws:cognito-idp:us-east-1:123456789:userpool/us-east-1_abc"]

  endpoints = [
    {
      path                 = "/login"
      http_method          = "POST"
      lambda_function_name = "login-handler"
      authorizer_type      = "NONE"
      authorizer_id        = null
      authorization_scopes = []
    },
    {
      path                 = "/profile"
      http_method          = "GET"
      lambda_function_name = "profile-handler"
      authorizer_type      = "COGNITO"
      authorizer_id        = null
      authorization_scopes = ["email", "openid"]
    }
  ]
}
```

### Proxy Routes `{proxy+}`

When `enable_proxy_routes = true`, for each non-root endpoint path the module automatically creates a `{proxy+}` child resource so that sub-routes are forwarded to the same Lambda. CORS `OPTIONS` is also created if `enable_cors = true`.

```hcl
module "my_api" {
  source   = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  api_name = "gateway"

  enable_proxy_routes = true  # creates /users/{proxy+}, /orders/{proxy+}, etc.

  endpoints = [
    {
      path                 = "/users"
      http_method          = "GET"
      lambda_function_name = "users-handler"
      authorizer_type      = "COGNITO"
      authorizer_id        = null
      authorization_scopes = ["openid"]
    },
    {
      path                 = "/orders"
      http_method          = "GET"
      lambda_function_name = "orders-handler"
      authorizer_type      = "COGNITO"
      authorizer_id        = null
      authorization_scopes = ["openid"]
    }
  ]
}
# Result: GET /users, ANY /users/{proxy+}, GET /orders, ANY /orders/{proxy+}
```

> The `{proxy+}` method inherits the authorizer and Lambda of the **first** endpoint defined for that path.

### WebSocket API

```hcl
module "my_api" {
  source   = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  api_name = "gateway"
  endpoints = []  # REST endpoints as usual

  enable_websocket = true

  websocket_routes = [
    {
      route_key            = "$connect"
      lambda_function_name = "ws-connect-handler"
      authorization_type   = "NONE"
    },
    {
      route_key            = "$disconnect"
      lambda_function_name = "ws-disconnect-handler"
      authorization_type   = "NONE"
    },
    {
      route_key            = "$default"
      lambda_function_name = "ws-message-handler"
      authorization_type   = "NONE"
    },
    {
      route_key            = "sendMessage"
      lambda_function_name = "ws-send-message-handler"
      authorization_type   = "NONE"
    }
  ]
}

# Access the WebSocket endpoint
output "ws_url" {
  value = module.my_api.websocket_api_endpoint
  # wss://<id>.execute-api.<region>.amazonaws.com/<environment>
}
```

### Custom Domains

```hcl
module "my_api" {
  source   = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  api_name = "gateway"
  endpoints = [ ... ]

  # REST API custom domain
  custom_domain_name            = "api.example.com"
  custom_domain_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/abc-123"
  custom_domain_base_path       = ""  # root path

  # WebSocket custom domain
  enable_websocket                        = true
  websocket_custom_domain_name            = "ws.example.com"
  websocket_custom_domain_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/xyz-456"
  websocket_routes = [ ... ]
}

# Use these outputs to create DNS records (e.g. in a Route53 module)
output "rest_dns_target"      { value = module.my_api.custom_domain_regional_domain_name }
output "rest_hosted_zone_id"  { value = module.my_api.custom_domain_hosted_zone_id }
output "ws_dns_target"        { value = module.my_api.websocket_custom_domain_target }
output "ws_hosted_zone_id"    { value = module.my_api.websocket_custom_domain_hosted_zone_id }
```

> **Note:** The ACM certificate must be in the **same AWS region** as the API. Custom domains require a DNS record (CNAME or Route53 alias) pointing to the output domain names above.

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
