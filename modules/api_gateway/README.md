# 🚪 AWS API Gateway REST Module (Advanced Edition)

High-performance Terraform module to manage Amazon API Gateway with **Integrated Security**. It automates endpoint creation, Lambda integrations, CORS management, and Cognito/Lambda Authorizers.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `api_name` | Base name for the REST API. | `string` | - | **Yes** |
| `environment` | develop/production. | `string` | - | **Yes** |
| `endpoints` | List of paths and methods. [See Endpoint Configuration](#-endpoint-configuration-details) | `list(obj)` | - | **Yes** |
| `cognito_user_pool_arns` | Cognito ARNs for automatic authorizer. | `list(string)` | `[]` | No |
| `enable_cors` | Global CORS toggle. | `bool` | `true` | No |
| `throttling_rate_limit` | Requests per second limit. | `number` | `1000` | No |
| `enable_access_logs` | CloudWatch logging toggle. | `bool` | `true` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `api_id` | The ID of the REST API. |
| `api_url` | The base URL of the deployed stage. |
| `execution_arn` | ARN for Lambda permissions. |
| `authorizer_id` | ID of the created Cognito Authorizer (if any). |

---

## 🧠 Endpoint Configuration (Details)

Each entry in the `endpoints` list supports advanced security settings:

| Attribute | Description | Options |
| :--- | :--- | :--- |
| `path` | Resource path (e.g., `/users`). | String |
| `http_method` | Verb (GET, POST, etc.). | String |
| `authorizer_type` | Security model. | `NONE`, `COGNITO`, `CUSTOM` |
| `authorizer_id` | Required if type is `CUSTOM`. | String (Authorizer ID) |
| `authorization_scopes` | OAuth Scopes for Cognito. | `list(string)` |

### 🔐 Example: Secure vs Public Endpoints
```hcl
module "my_api" {
  source   = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/api_gateway?ref=main"
  api_name = "gateway"
  
  cognito_user_pool_arns = ["arn:aws:cognito-idp:..."]

  endpoints = [
    {
      path            = "/login"
      http_method     = "POST"
      authorizer_type = "NONE" # Public
      lambda_function_name = "login-handler"
    },
    {
      path            = "/profile"
      http_method     = "GET"
      authorizer_type = "COGNITO" # Protected
      lambda_function_name = "profile-handler"
      authorization_scopes = ["email", "openid"]
    }
  ]
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
