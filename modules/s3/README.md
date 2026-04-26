# AWS S3 Module

Generic module for secure S3 buckets with versioning, encryption, and lifecycle management.

## Features
- **Security First**: Blocks all public access by default.
- **Encryption**: AES-256 server-side encryption.
- **Versioning**: Optional versioning for data recovery.
- **Lifecycle Rules**: Automatically cleans up incomplete uploads and old versions.
- **Bucket Policy**: Support for custom JSON policies (e.g., for CloudFront access).

## Inputs
| Name | Description | Type | Default |
|---|---|---|---|
| `bucket_name` | Unique name of the bucket | `string` | - |
| `enable_versioning` | Enable object versioning | `bool` | `true` |
| `bucket_policy` | Custom JSON policy | `string` | `null` |

## Outputs
| Name | Description |
|---|---|
| `bucket_id` | Name/ID of the bucket |
| `bucket_arn` | ARN of the bucket |
| `bucket_domain_name` | Regional domain name of the bucket |
