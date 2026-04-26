# Bootstrap Stack

This stack is the foundation for any new AWS project within the organization. It sets up the necessary resources for Terraform state management and GitHub Actions integration.

---

## 🛠️ Resources Created

1.  **S3 Bucket**: A secure, versioned bucket for Terraform state storage (`${project}-terraform-state-${env}`).
2.  **IAM OIDC Provider**: Configures Trust with GitHub for passwordless authentication.
3.  **IAM Roles**:
    - `GithubActionsRole`: Used by workflows to deploy resources.
    - Restricted Trust Policy: Only allows repositories from `Remsoft-SAS/*` to assume the role.

## 📥 Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| `project_name` | Name of the project (e.g., `rempays`) | `string` | **Yes** |
| `environment` | `develop` or `production` | `string` | **Yes** |
| `region` | AWS Region | `string` | No (Default: `us-east-1`) |

## 📝 Usage Example

```hcl
module "bootstrap" {
  source = "git::https://github.com/Remsoft-SAS/IaC-core.git//stacks/bootstrap?ref=main"

  project_name = "myproject"
  environment  = "develop"
}
```

## ⚠️ Important Note
This stack should be run **manually** once from a local machine or a special bootstrap runner before the standard CI/CD can work, as it creates the roles needed for the CI/CD itself.
