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
| `throttling_burst_limit` | Maximum burst limit for throttling. | `number` | `500` | No |
| `throttling_rate_limit` | Requests per second limit. | `number` | `1000` | No |
| `enable_access_logs` | CloudWatch access logs toggle. | `bool` | `true` | No |
| `log_retention_days` | Log retention in days. | `number` | `7` | No |
| `tags` | Additional resource tags. | `map(string)` | `{}` | No |

### WebSocket API (API Gateway V2)

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `enable_websocket` | Enable a WebSocket API alongside the REST API. | `bool` | `false` | No |
| `websocket_routes` | List of WebSocket routes. See [WebSocket Routes](#websocket-route-configuration). | `list(obj)` | `[]` | No |
| `websocket_api_name` | Name override for the WebSocket API. | `string` | `"<api_name>-websocket-<env>"` | No |
| `websocket_route_selection_expression` | Expression used to select the route. | `string` | `"$request.body.action"` | No |

## Outputs

### REST API

| Name | Description |
| :--- | :--- |
| `api_id` | The ID of the REST API. |
| `api_arn` | The ARN of the REST API. |
| `invoke_url` | Base URL to invoke the REST API. |
| `execution_arn` | Execution ARN for Lambda permissions. |
| `stage_name` | Deployed stage name. |

### WebSocket API

| Name | Description |
| :--- | :--- |
| `websocket_api_id` | WebSocket API ID (`null` if disabled). |
| `websocket_api_endpoint` | WebSocket endpoint `wss://...` (`null` if disabled). |
| `websocket_execution_arn` | Execution ARN for granting Lambda invoke permissions (`null` if disabled). |

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

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
