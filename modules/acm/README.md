# AWS ACM Module

Requests SSL/TLS certificates with automatic DNS validation via Route 53.

## Features
- **Auto-Validation**: Creates the necessary DNS records to validate the certificate.
- **Wait Logic**: Terraform waits until the certificate is issued before continuing.

## Inputs
| Name | Description | Type | Default |
|---|---|---|---|
| `domain_name` | Main domain for the certificate | `string` | - |
| `zone_id` | Route 53 Zone ID for validation | `string` | - |
