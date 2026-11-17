# WAF rate-limit module

Creates a Regional AWS WAF Web ACL with a source-IP rate-based blocking rule.
The Web ACL can be associated with one or more API Gateway REST API stages.

Defaults allow up to 10,000 requests per IP in a rolling five-minute window.
The threshold and evaluation window can be overridden per API. Keep thresholds
high for webhook APIs where upstream providers may use shared egress IPs.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `name` | Web ACL and CloudWatch metric name | Required |
| `description` | Web ACL description | `Regional IP rate limiting` |
| `rule_name` | Rate rule name | `rate-limit-by-source-ip` |
| `rate_limit_per_5m` | Requests per IP before blocking | `10000` |
| `evaluation_window_sec` | Rolling window: 60, 300, 600, or 1200 seconds | `300` |
| `resource_arns` | API Gateway REST stage ARNs associated with this ACL | `[]` |
| `metric_name` | Optional rule metric name | `${name}-rate-limit` |
| `tags` | Web ACL tags | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `web_acl_arn` | Web ACL ARN |
| `web_acl_id` | Web ACL ID |
