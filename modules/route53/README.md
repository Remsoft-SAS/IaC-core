# Route 53 Module

Manages AWS Route 53 Hosted Zones and DNS records (A, CNAME, TXT, Alias, etc.).

---

## 📥 Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `domain_name` | Domain name | `string` | **Yes** | - |
| `environment` | Target environment (develop/production) | `string` | **Yes** | - |
| `create_zone` | Whether to create a new hosted zone | `boolean` | No | `true` |
| `zone_id` | Hosted zone ID (if `create_zone` is `false`) | `string` | No | `null` |
| `records` | List of records to create | `list(object)` | No | `[]` |
| `tags` | Additional tags for the resource | `map(string)` | No | `{}` |

## 📤 Outputs

| Name | Description |
|---|---|
| `zone_id` | Hosted zone ID |
| `name_servers` | List of name servers for domain registration |
| `records` | Map of created records (name => fqdn) |

## 📝 Usage Example

```hcl
module "dns" {
  source = "../../modules/route53"

  domain_name = "rempays.com"
  environment = "production"
  records = [
    {
      name = "api"
      type = "A"
      alias = {
        name                   = module.api_gw.domain_name
        zone_id                = module.api_gw.zone_id
        evaluate_target_health = true
      }
    }
  ]
}
```
