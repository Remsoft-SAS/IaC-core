# 📦 AWS S3 Advanced Storage Module

Enterprise-grade Terraform module to manage Amazon S3 buckets with built-in **Smart Access Control (OAC)**, Cost Optimization (Lifecycle Rules), and Static Hosting capabilities.

## 🌟 Key Features
- **Smart OAC Integration:** Automatically manages bucket policies for CloudFront OAC when a Distribution ARN is provided.
- **Cost Optimization:** Multi-tier lifecycle rules supporting Standard-IA and Glacier transitions.
- **Dual-Purpose:** Easily switch between high-performance storage and static website hosting.
- **Security-First:** Automatic public access block, server-side encryption (AES256/KMS), and versioning control.
- **Clean Infrastructure:** Automatically aborts incomplete multipart uploads to save space and costs.

## 📥 Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `bucket_name` | Globally unique name for the bucket. | `string` | - | **Yes** |
| `environment` | develop/production. | `string` | - | **Yes** |
| `cloudfront_distribution_arn` | ARN for OAC access. [See OAC Setup](#-smart-oac-setup) | `string` | `null` | No |
| `enable_website_hosting` | Toggle static web hosting. | `bool` | `false` | No |
| `transition_to_ia_days` | Days before Standard-IA. | `number` | `null` | No |
| `transition_to_glacier_days` | Days before Glacier. | `number` | `null` | No |
| `enable_versioning` | Toggle object versioning. | `bool` | `true` | No |

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `bucket_id` | The name (ID) of the bucket. |
| `bucket_arn` | The ARN of the bucket. |
| `bucket_regional_domain_name` | Domain name for CloudFront origins. |
| `website_endpoint` | Endpoint URL (if hosting is enabled). |

---

## 🧠 Smart OAC Setup

This module simplifies the connection between CloudFront and S3. By providing the `cloudfront_distribution_arn`, the module will automatically create a secure bucket policy that allows CloudFront to fetch objects while keeping the bucket private.

```hcl
module "assets" {
  source      = "..."
  bucket_name = "my-app-assets"
  
  # Just pass the ARN, the module handles the IAM policy
  cloudfront_distribution_arn = module.cdn.arn
}
```

---
*Created by Remsoft SAS - Infrastructure as Code Standard.*
