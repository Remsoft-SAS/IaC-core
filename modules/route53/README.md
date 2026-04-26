# AWS Route 53 Module

Manages Route 53 Hosted Zones and DNS records.

## Features
- **Zone Creation**: Optional creation of public hosted zones.
- **Record Management**: Create A, CNAME, TXT, and Alias records dynamically.

## Outputs
| Name | Description |
|---|---|
| `zone_id` | ID of the hosted zone |
| `name_servers` | List of name servers to configure in registrars (e.g., Hostinger) |
