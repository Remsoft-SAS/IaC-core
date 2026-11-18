# Contributing to IaC-core

Contributions to documentation, bug fixes, examples, and reusable AWS Terraform modules are welcome. This guide explains how to prepare a change that maintainers and module consumers can review.

To use the modules, start with the [README](./README.md). This repository is a library of independent child modules, not a deployable root stack. Read the affected module's README and Terraform source before changing its behavior.

## Report a bug or propose a feature

Open an issue in [Remsoft-SAS/IaC-core](https://github.com/Remsoft-SAS/IaC-core/issues). Search existing issues first. For substantial features, new modules, or breaking changes, describe the proposal before investing in a large implementation so maintainers can discuss scope.

For a bug report, include:

- The affected module and Git commit or tag used by the caller.
- Terraform and provider versions, AWS region, and relevant enabled features.
- A minimal configuration with credentials and private identifiers removed.
- Expected behavior, actual behavior, and the relevant sanitized error message.
- Whether the problem occurs during init, validate, plan, apply, or destroy, and whether it affects an existing deployment or a new one.

For a feature request, explain the use case, proposed inputs and outputs, and how existing callers would be affected. Documentation corrections and small fixes can go directly to a pull request.

Do not attach state files, saved plans, credentials, or secret parameter values to public issues. For a vulnerability, use GitHub's private vulnerability reporting option if enabled. Otherwise, request a private reporting channel from the maintainers without posting exploit details or sensitive information publicly.

## Set up your contribution

1. Fork the repository on GitHub.
2. Clone your fork and create a branch for one focused change.
3. Follow the [requirements and provider guidance](./README.md#requirements).

Replace `YOUR-USERNAME` with your GitHub username:

```bash
git clone https://github.com/YOUR-USERNAME/IaC-core.git
cd IaC-core
git remote add upstream https://github.com/Remsoft-SAS/IaC-core.git
git switch -c fix/sqs-description
```

Use a descriptive branch name such as `fix/sqs-description`, `docs/lambda-deployment`, or `feat/new-module`. There is no required commit-message convention; make the intent clear.

## Module structure

The current module catalog is in the [root README](./README.md#modules). Each module must include:

| File | Responsibility |
| --- | --- |
| `main.tf` | Resources, data sources, and supporting locals. |
| `variables.tf` | Public inputs, descriptions, types, defaults, and applicable validation. |
| `outputs.tf` | Useful resource identifiers and integration values, with descriptions. |
| `README.md` | Usage, prerequisites, behavior, complete inputs and outputs, and limitations. |

Additional Terraform files are appropriate when they make a module easier to navigate. For a new module, choose a clear lowercase directory name and add it to the root module catalog. Existing paths use both underscores and hyphens; preserve them because consumers reference those paths in Git module sources.

Keep modules focused on a reusable capability. Application code, account-specific configuration, provider credentials, and state backends belong in the caller's project.

## Implementation conventions

### Inputs, outputs, and providers

- Give each new input and output a clear English description. Use explicit types and structured objects instead of `any` when the contract is known.
- Document whether an optional input becomes required when a feature is enabled. Add validation for invalid combinations and service limits when feasible.
- Choose defaults deliberately. Explain cost, retention, encryption, and deletion behavior instead of relying on the environment name to imply them.
- Expose IDs, ARNs, names, or endpoints needed to compose modules. Mark secret-bearing inputs and outputs sensitive where appropriate; sensitivity does not remove values from state.
- Configure provider instances and backends in the caller. When adding provider requirements, declare the provider source and justified compatibility constraints; explain and validate any increase to the supported Terraform or provider baseline.
- Do not introduce credentials, fixed account IDs, customer domains, or project-specific resource names. Use `example.com` and placeholder identifiers in documentation. Prefer partition-aware ARN construction in new code.
- Support additional tags where the AWS resource supports them. Preserve existing naming and tag behavior; do not add inputs that are accepted but unused.

### Dependencies and permissions

- Prefer references between resource attributes to establish dependencies. Use `depends_on` only when an actual dependency is otherwise invisible to Terraform.
- Keep resource `count` and `for_each` decisions determinable at plan time. A new resource ARN can be unknown during the first plan; use stable keys or an explicit feature flag where needed.
- Scope IAM actions, resources, and service-principal conditions to the intended integration. Explain any required wildcard permissions.
- State which integration resources are created and which callers must supply. An invoke permission alone does not create an SNS subscription, S3 notification, or API integration.
- Avoid introducing shell provisioners when a provider resource can manage the operation. If a provisioner is unavoidable, document execution-host tools, credential/region handling, quoting, and lifecycle behavior.

### Compatibility and lifecycle

Treat variable names and types, outputs, module paths, resource addresses, defaults, and naming rules as part of the module's public contract.

A change can be breaking even if Terraform accepts the configuration. Examples include renaming a resource, changing a bucket name, reducing retention, tightening permissions, changing a default feature flag, or changing an output from a name to an ARN.

For a potentially breaking change:

1. Describe the old and new behavior and identify affected callers.
2. Prefer a compatible opt-in path when practical.
3. Include migration instructions and explain any replacement, downtime, or data-loss implications.
4. Use a `moved` block for a supported resource-address refactor when it preserves existing state; document manual state operations only when necessary.
5. Review a plan against representative existing state as well as a fresh configuration when you have an appropriate test environment.

Existing behavior deserves particular care: Lambda ignores several code/environment changes, Cognito ignores schema changes and protects production pools from deletion, SSM separates externally managed values into different resource addresses, and S3 expires noncurrent versions by default. Consult the relevant README before changing these contracts.

## Documentation expectations

Keep repository documentation in English for a shared contributor reference. Update the affected module README in the same pull request as its implementation.

Use the current module READMEs as examples and include:

- A short purpose statement and links to the root setup guide.
- A usable module block containing all required inputs. Identify external prerequisites and placeholders explicitly.
- Behavior and requirements, including region restrictions, IAM/KMS responsibilities, resource naming, lifecycle behavior, and known limitations.
- Resources and data sources, distinguishing optional features from unconditional resources.
- Every input's name, description, exact type, default, and required status; include full object schemas.
- Every output and its meaning, including null values or differences between creation and reuse modes.
- Integration examples where the relationship between modules needs explanation.

Use the repository's actual Git subdirectory source paths. `ref=main` is acceptable for introductory examples if the text recommends pinning a reviewed commit or existing tag. Do not invent release tags, claim untested version compatibility, or describe an input as functional when it is unused.

## Validate your change

This repository currently has no shared automated integration test suite or compatibility matrix. Report the checks you actually performed and their limits; do not describe a configuration as deployed when only syntax was checked.

### Documentation changes

Check relative links and heading anchors, compare input/output tables with the Terraform source, and verify HCL snippets. Copy complete configuration examples into a temporary `.tf` file to check their syntax with `terraform fmt`; object type fragments need a surrounding variable declaration. Documentation-only edits do not require deploying AWS resources.

### Terraform changes

From the repository root, format the affected module and check the diff. Replace `modules/sqs` with the directory you changed:

```bash
terraform fmt -recursive modules/sqs
terraform fmt -check -recursive modules/sqs
git diff --check
```

Check repository-wide formatting when relevant with `terraform fmt -check -recursive`. If it reports unrelated pre-existing formatting problems, identify them separately rather than mixing a broad reformat into a focused fix.

Initialize and validate the affected module:

```bash
terraform -chdir=modules/sqs init -backend=false
terraform -chdir=modules/sqs validate
```

Initialization downloads providers and requires network access. Standalone validation checks configuration structure; it does not supply the caller's input values or prove that an AWS deployment will succeed. It also does not validate every other module in this repository.

For integration checks, create a separate caller outside the repository with a local source such as `../IaC-core/modules/sqs`. Configure providers and required inputs there. This isolates test state and artifacts from the library. Pin the provider version under test in that caller and record the resolved version from its lock file.

Run in the test caller:

```bash
terraform init
terraform validate
terraform plan
```

For changes to optional behavior, check both enabled and disabled configurations; for example, SQS with and without a DLQ, or a resource created by the module versus an existing-resource input. Include relevant cross-module connections and first-apply unknown values when they relate to the fix.

An AWS plan needs credentials and can read account resources. Apply only in an account where you are authorized to create test infrastructure, review the plan first, and clean up resources you created when testing is complete. If AWS testing is unavailable, state that in the pull request and provide the static checks and reproduction configuration you could verify.

Do not commit `.terraform/`, state, saved plans, credentials, generated Lambda ZIPs, or private variable files. The current `.gitignore` does not cover every generated artifact, so inspect `git status --short` before committing. Provider lock files belong in deployable caller projects; avoid adding incidental lock files produced by standalone child-module validation.

## Submit a pull request

Push your branch to your fork and open a pull request against `Remsoft-SAS/IaC-core`'s `main` branch. Keep the diff focused and explain the problem and resulting behavior so a reviewer can assess it without reading a separate conversation.

Use this outline in the pull request description:

```markdown
## Change

What problem does this solve, and what does the caller experience now?
Link a related issue if one exists.

## Compatibility

Identify affected modules and any input/output, default, IAM, or lifecycle changes.
Describe migration steps and resource replacements, or state why none are expected.

## Validation

List the commands and configurations checked, Terraform/provider versions,
and results. State whether an AWS plan or apply was performed and what remains
untested. Include sanitized evidence only.
```

Before requesting review:

- Ensure the implementation, examples, and reference tables agree.
- Check formatting and validation appropriate to the change.
- Explain any new permissions, cost implications, or resource replacements.
- Inspect the diff for unrelated changes and sensitive or generated files.
- Update the root module catalog if a module was added.

Maintainers may request changes before merging. A pull request does not require you to publish a release or deploy infrastructure in a maintainer's AWS account.

## License status

The repository currently has no `LICENSE` file. See the [license status](./README.md#license); this guide does not establish licensing terms or ask contributors to accept a separate contributor agreement. Maintainers should establish the project license before presenting it as a licensed open-source project.
