# IaC-core: AWS Terraform modules

Reusable AWS Terraform modules maintained by Remsoft SAS. Use individual modules from Git, clone the repository to inspect their implementation, or compose them in your own Terraform root configuration.

This repository is a module library: there is no root infrastructure stack to deploy. Each directory under `modules/` contains `main.tf`, `variables.tf`, `outputs.tf`, and a README with examples, complete inputs/outputs, and operational limitations.

## Modules

| Module | Purpose |
| --- | --- |
| [ACM certificates](./modules/acm/README.md) | Creates a DNS-validated ACM certificate and Route 53 validation records. |
| [API Gateway REST and WebSocket APIs](./modules/api_gateway/README.md) | Creates a Regional REST API with Lambda proxy integrations and optional WebSocket API, domains, DNS, and access logs. |
| [CloudFront distribution](./modules/cloudfront/README.md) | Creates a distribution with a private S3 origin, Origin Access Control, security headers, optional API origin, URL rewriting, and DNS. |
| [Cognito user pool](./modules/cognito/README.md) | Creates a user pool and app client with password policies, TOTP MFA, Lambda triggers, optional social providers, and a custom domain. |
| [DynamoDB table](./modules/dynamodb/README.md) | Creates a table with optional secondary indexes, TTL, streams, point-in-time recovery, KMS encryption, and regional replicas. |
| [EventBridge event bus](./modules/eventbridge/README.md) | Creates a custom event bus or exposes an existing bus ARN without creating resources. |
| [Lambda function](./modules/lambda/README.md) | Creates a ZIP-based Lambda function, execution role, log group, optional VPC attachment, and event-source permissions or mappings. |
| [Lambda layer](./modules/lambda_layer/README.md) | Publishes a Lambda layer version from a ZIP file or S3 object, with optional cross-account permissions. |
| [SSM Parameter Store](./modules/parameter-store/README.md) | Creates named parameters with Terraform-managed or externally managed values. |
| [Route 53 hosted zone and records](./modules/route53/README.md) | Creates a public hosted zone and DNS records, or manages records in an existing zone. |
| [S3 bucket](./modules/s3/README.md) | Creates a private bucket with encryption, versioning, lifecycle cleanup, optional CORS, and CloudFront access policies. |
| [SNS topic](./modules/sns/README.md) | Creates a standard or FIFO topic with KMS encryption and an optional publisher policy. |
| [SQS queue](./modules/sqs/README.md) | Creates a standard or FIFO queue, optional dead-letter queue, and optional SNS subscription with a queue policy. |
| [Step Functions state machine](./modules/step_functions/README.md) | Creates a state machine, execution IAM role, CloudWatch log group, and optional EventBridge trigger. |
| [WAF Regional IP rate limit](./modules/waf_rate_limit/README.md) | Creates a Regional WAFv2 Web ACL with one blocking IP rate rule and optional resource associations. |

## Requirements

- Terraform 1.3 or later is needed for the optional object attributes used by this library. The modules do not declare `required_version`; this is a language-feature baseline, not a tested compatibility matrix.
- Configure `hashicorp/aws` in your calling root module. This repository does not declare provider version constraints or a tested minimum AWS provider version. Select and lock a provider version that supports the resources you use, including newer WAF evaluation-window settings.
- The Lambda module also uses `hashicorp/archive` and `hashicorp/null`. With nonempty environment variables, it requires AWS CLI and `jq` on the Terraform execution host.
- Git is required for cloning and `git::` module sources. AWS credentials must have permission to manage the selected resources and, where applicable, IAM roles and policies.

The following provider configuration is an example starting point, not a claim that every module has been tested with every AWS 6.x version. Validate your chosen provider version and commit your root project's `.terraform.lock.hcl`.

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

For Lambda callers, add `archive = { source = "hashicorp/archive", version = "~> 2.0" }` and `null = { source = "hashicorp/null", version = "~> 3.0" }` inside `required_providers`.

Use your normal AWS credential chain, such as an AWS CLI SSO profile. Do not put access keys into Terraform files:

```bash
aws sso login --profile your-profile
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
aws sts get-caller-identity
```

For multiple regions, define provider aliases in your root configuration and pass the appropriate provider with `providers = { aws = aws.us_east_1 }`. CloudFront certificate lookup uses the provider it receives, so pass a us-east-1 provider for custom certificates. See the Cognito README for its same-provider custom-domain limitation.

## Quick start: reference a module from Git

Create a separate project directory and save the provider configuration above in `main.tf`. Append this queue module and output:

```hcl
module "jobs" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/sqs?ref=main"

  queue_name  = "example-jobs"
  environment = "develop"
  tags = {
    Project = "example"
  }
}

output "jobs_queue_url" {
  value = module.jobs.queue_url
}
```

Run from that calling project directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output jobs_queue_url
```

Applying creates billable AWS resources. Review the plan before applying. For a disposable example, use `terraform plan -destroy -out=destroy.tfplan`, review it, and run `terraform apply destroy.tfplan` when you are ready to remove the resources. Protect saved plans because they can contain sensitive values.

### Source paths and version pinning

The double slash before `modules/sqs` selects a subdirectory of this Git repository; `?ref=` comes after that subdirectory. These are Git sources, not Terraform Registry modules, so the module `version` argument does not apply.

Examples use `ref=main` for discoverability. For reproducible deployments, replace `main` with a reviewed full commit SHA or an existing release tag. Do not assume a particular release tag exists. A provider lock file locks providers, not Git module revisions. Review changes before updating the ref and re-running `terraform init`; `terraform init -upgrade` can refresh module and provider selections within your configured constraints.

## Clone and use locally

```bash
git clone https://github.com/Remsoft-SAS/IaC-core.git
mkdir example-infra
cd example-infra
```

Add the provider configuration to `example-infra/main.tf` and use a source relative to that file:

```hcl
module "jobs" {
  source = "../IaC-core/modules/sqs"

  queue_name  = "example-jobs"
  environment = "develop"
}
```

Run the same init, validate, plan, and apply workflow in `example-infra`. Running Terraform at the library root does not deploy its subdirectories. Local module sources track your checkout; they do not accept a Git `ref` query.

## Compose modules

Use outputs to connect modules and pass the same environment consistently. For example, create an event bus and a workflow that reacts to events on it:

```hcl
module "events" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/eventbridge?ref=main"

  bus_name    = "example-events"
  environment = "develop"
}

module "workflow" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//modules/step_functions?ref=main"

  name        = "example-workflow"
  environment = "develop"
  type        = "STANDARD"
  definition = jsonencode({
    StartAt = "Done"
    States  = { Done = { Type = "Succeed" } }
  })
  eventbridge_trigger = {
    bus_name = module.events.bus_name
    event_pattern = jsonencode({
      source = ["example.application"]
    })
  }
}
```

Other common combinations are [S3 + CloudFront](./modules/cloudfront/README.md#private-s3-integration), [Lambda + SQS](./modules/lambda/README.md#sqs-consumer), [ACM](./modules/acm/README.md) with [API Gateway](./modules/api_gateway/README.md), and a REST API stage with [WAF rate limiting](./modules/waf_rate_limit/README.md). Each module README explains which permissions and integration resources the module creates and which the caller supplies.

## Conventions and deployment considerations

- Most service names append `-environment`; S3 bucket names, SSM parameter paths, and WAF names are used verbatim. `environment` is generally a caller-defined string; `develop` and `production` are examples. Cognito specifically enables deletion protection for `production`.
- Providers and state backends belong in the calling project. Configure remote state with encryption, access controls, and locking appropriate to your backend. Never commit state, credentials, sensitive variable files, or saved plans. The current `.gitignore` does not ignore saved plan files.
- KMS keys, key policies, DNS delegation, application artifacts, and account-level API Gateway logging configuration are not automatically supplied by this library.
- Feature flags used for resource counts should be known at plan time. For example, use Lambda `event_source_type` with a computed event ARN and S3 `enable_oac_policy` when connecting a new CloudFront distribution.
- Inspect lifecycle behavior before adopting a module. Lambda delegates later code deployment to an external pipeline; SSM can ignore value updates; Cognito ignores schema changes; S3 expires noncurrent versions by default.
- The implementation contains hard-coded `arn:aws` values in several modules. AWS GovCloud and China partition compatibility is not guaranteed.
- There is no repository-wide automated compatibility test suite or release support matrix. `terraform validate` checks configuration, but a plan in your account is still needed to assess IAM permissions, resource availability, region constraints, and replacements.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Module cannot be downloaded | Check repository access, Git installation, the `//modules/<directory>` path, and whether the requested ref exists. |
| Invalid count / value known only after apply | Use the module's explicit feature flags and read its plan-time requirements. |
| API returns an integration error | Verify the Lambda base name/environment suffix, invoke permission, region, and proxy response format. |
| CloudFront returns S3 AccessDenied | Use the S3 regional endpoint, enable the OAC bucket policy, and provide the distribution ARN; check KMS policy if used. |
| Certificate lookup or validation fails | Check the passed provider region, exact lookup domain, certificate status, DNS records, and public zone delegation. |
| Terraform does not update Lambda code or remove environment keys | Review the Lambda lifecycle and CLI merge behavior; use your application deployment process. |
| Destroy fails | Check Cognito production deletion protection, nonempty S3 buckets, and dependencies outside this state. |

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Keep module READMEs in English and update examples, all input types/defaults, outputs, and behavior notes alongside code changes. Use generic example domains and account IDs. Include validation results and describe breaking changes in pull requests.

For documentation-only changes, check Markdown links, compare reference tables with `variables.tf` and `outputs.tf`, and parse/format the HCL examples. For implementation changes, run `terraform fmt -check -recursive`, initialize the affected module or caller with `terraform init -backend=false`, and run `terraform validate`. Test a representative plan in an appropriate AWS account; do not assume standalone validation proves an integration works.

## License

Copyright 2026 Remsoft SAS.

Licensed under the [Apache License, Version 2.0](./LICENSE) (`Apache-2.0`). You may use, modify, and redistribute these modules, including commercially, subject to the license terms. The software is provided without warranties. See [NOTICE](./NOTICE) for attribution.
