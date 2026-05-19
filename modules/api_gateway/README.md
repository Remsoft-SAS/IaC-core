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
| `enable_cors` | Global CORS toggle. Enables OPTIONS methods for all endpoints. | `bool` | `true` | No |
| `cors_allow_origin` | Value for `Access-Control-Allow-Origin` header. | `string` | `"*"` | No |
| `cors_allow_credentials` | Value for `Access-Control-Allow-Credentials` header. | `bool` | `false` | No |
| `enable_proxy_routes` | Auto-create `{proxy+}` child resource per endpoint path (e.g. `/users/{proxy+}`) with `ANY` method. Includes CORS support when `enable_cors = true`. | `bool` | `false` | No |
| `throttling_burst_limit` | Maximum burst limit for throttling (requests). | `number` | `500` | No |
| `throttling_rate_limit` | Maximum rate limit for throttling (requests per second). | `number` | `1000` | No |
| `enable_access_logs` | CloudWatch access logs toggle. **Note:** Requires CloudWatch Logs role ARN configured at account level (aws_api_gateway_account). Defaults to false to avoid deployment errors. | `bool` | `false` | No |
| `access_log_format` | Custom format for REST API access logs (CloudWatch). | `string` | JSON preset | No |
| `log_retention_days` | Log retention in days for CloudWatch. | `number` | `7` | No |
| `manage_api_gateway_account` | Whether to manage the account-wide API Gateway CloudWatch role. | `bool` | `false` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

### WebSocket API (API Gateway V2)

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `enable_websocket` | Enable a WebSocket API (API Gateway V2) alongside the REST API. | `bool` | `false` | No |
| `websocket_routes` | List of WebSocket routes. See [WebSocket Routes Configuration](#websocket-route-configuration). | `list(obj)` | `[]` | No |
| `websocket_api_name` | Name override for the WebSocket API. Defaults to `<api_name>-websocket-<environment>`. | `string` | `""` | No |
| `websocket_route_selection_expression` | Expression to select the route from the request body. Standard: `$request.body.action`. | `string` | `"$request.body.action"` | No |
| `websocket_enable_access_logs` | CloudWatch access logs toggle for WebSocket API. **Note:** Requires CloudWatch Logs role ARN configured at account level. | `bool` | `false` | No |
| `websocket_access_log_format` | Log format for WebSocket API access logs. | `string` | JSON preset with `connectionId`, `routeKey`, `status` | No |

### Custom Domain — REST API

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `custom_domain_name` | Custom domain for the REST API (e.g., `api.example.com`). Leave empty to skip. | `string` | `""` | No |
| `custom_domain_certificate_arn` | ACM certificate ARN for the REST API domain (must be in the same region). | `string` | `""` | No |
| `custom_domain_base_path` | Base path mapping for the REST API custom domain. Empty string maps to the root path. | `string` | `""` | No |

### Custom Domain — WebSocket API

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `websocket_custom_domain_name` | Custom domain for the WebSocket API (e.g., `ws.example.com`). Leave empty to skip. | `string` | `""` | No |
| `websocket_custom_domain_certificate_arn` | ACM certificate ARN for the WebSocket custom domain (must be in the same region). | `string` | `""` | No |

### Route53 Integration

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `route53_zone_id` | Route53 hosted zone ID. When provided, the module automatically creates alias A records for custom domains. | `string` | `""` | No |

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
| `websocket_api_id` | WebSocket API ID (API Gateway V2). `null` if `enable_websocket = false`. |
| `websocket_api_endpoint` | WebSocket endpoint URL starting with `wss://`. `null` if disabled. |
| `websocket_execution_arn` | Execution ARN for granting Lambda invoke permissions. `null` if disabled. |

### Custom Domains & Route53

| Name | Description |
| :--- | :--- |
| `custom_domain_regional_domain_name` | Regional domain name for REST API custom domain (use as Route53 CNAME/ALIAS target). `null` if not configured. |
| `custom_domain_target` | Same as `custom_domain_regional_domain_name`. |
| `custom_domain_hosted_zone_id` | Hosted zone ID for REST API Route53 alias record. `null` if not configured. |
| `websocket_custom_domain_target` | Regional domain name for WebSocket custom domain (use as Route53 CNAME target). `null` if not configured. |
| `websocket_custom_domain_hosted_zone_id` | Hosted zone ID for WebSocket custom domain Route53 alias record. `null` if not configured. |

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

---

## WebSocket Route Configuration

Each entry in the `websocket_routes` list supports:

| Attribute | Description | Example |
| :--- | :--- | :--- |
| `route_key` | WebSocket route identifier. Use `$connect`, `$disconnect`, `$default` for system routes, or custom action names. | `$connect`, `sendMessage`, `$default` |
| `lambda_function_name` | Lambda function name (without environment suffix). The module appends `-<environment>`. | `websocket-handler` |
| `authorization_type` | Authorization model for this route. | `NONE`, `AWS_IAM`, `CUSTOM`, `JWT` |

**Example Usage:**

```hcl
websocket_routes = [
  {
    route_key            = "$connect"
    lambda_function_name = "websocket-handler"
    authorization_type   = "NONE"
  },
  {
    route_key            = "$disconnect"
    lambda_function_name = "websocket-handler"
    authorization_type   = "NONE"
  },
  {
    route_key            = "sendMessage"
    lambda_function_name = "websocket-handler"
    authorization_type   = "NONE"
  }
]
```

---

## Custom Domains & Route53 Setup

### REST API Custom Domain

```hcl
module "api_gateway" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  
  api_name    = "my-api"
  environment = "production"
  
  custom_domain_name              = "api.example.com"
  custom_domain_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  custom_domain_base_path         = "v1"  # Optional: /v1/*
  
  route53_zone_id = "Z1234567890ABC"  # Automatically create Route53 alias record
}
```

### WebSocket Custom Domain

```hcl
module "api_gateway" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  
  enable_websocket                    = true
  websocket_custom_domain_name        = "ws.example.com"
  websocket_custom_domain_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
  
  route53_zone_id = "Z1234567890ABC"
}
```

---

## Access Logging Setup

### Prerequisites

API Gateway requires an account-level CloudWatch Logs role to be configured. You can either:

1. **Let Terraform manage it** (recommended):
```hcl
module "api_gateway" {
  source                    = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  manage_api_gateway_account = true
  enable_access_logs        = true
}
```

2. **Pre-configure the role manually** and set `manage_api_gateway_account = false`.

### Custom Log Format

```hcl
access_log_format = jsonencode({
  requestId   = "$context.requestId"
  ip          = "$context.identity.sourceIp"
  caller      = "$context.identity.caller"
  user        = "$context.identity.user"
  requestTime = "$context.requestTime"
  httpMethod  = "$context.httpMethod"
  resourcePath = "$context.resourcePath"
  status      = "$context.status"
  protocol    = "$context.protocol"
  responseLength = "$context.responseLength"
  error       = "$context.error.message"
})
```

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
