# API Gateway Module (REST)

Generic module to manage REST API Gateway with dynamic endpoints and methods.

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `api_name` | Name of the REST API | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `endpoints` | List of endpoints to create | `list(any)` | **Yes** | - |
| `description` | Description of the API | `string` | No | `"Managed by Terraform"` |
| `endpoint_type` | API endpoint type (EDGE, REGIONAL) | `string` | No | `"REGIONAL"` |
| `enable_cors` | Enable CORS for all resources | `boolean` | No | `true` |
| `cors_allow_origin` | Allowed origins for CORS | `string` | No | `"*"` |
| `enable_access_logs` | Enable CloudWatch Access Logs | `boolean` | No | `false` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `api_id` | API Gateway ID |
| `api_arn` | API Gateway ARN |
| `invoke_url` | Base URL to invoke the API |
| `stage_name` | API stage name |

## 📝 Usage Example

```hcl
module "api" {
  source = "../../modules/api_gateway"

  api_name    = "rempays-core"
  environment = "develop"
  endpoints   = [
    {
      path                = "users"
      http_method         = "GET"
      authorization       = "NONE"
      lambda_invoke_arn   = module.lambda_users.invoke_arn
      lambda_function_name = module.lambda_users.function_name
    }
  ]
}
```
