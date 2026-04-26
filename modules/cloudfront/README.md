# AWS CloudFront Module

CloudFront CDN for S3 buckets and custom origins with OAC support.

## Features
- **Origin Access Control (OAC)**: Secure access to S3 buckets without public access.
- **Custom Domains**: Support for CNAMEs and ACM certificates.
- **Protocol Policy**: Forced redirect to HTTPS.

## Outputs
| Name | Description |
|---|---|
| `distribution_domain_name` | CloudFront domain name |
| `distribution_arn` | ARN for S3 bucket policy conditions |
