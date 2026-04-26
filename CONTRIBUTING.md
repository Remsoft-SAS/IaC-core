# Contributing to IaC-core

This guide explains how to add a new atomic module to this repository. Following these standards ensures consistency and reusability across all Remsoft projects.

## 🛠️ Step-by-Step: Adding a New Module

### 1. Create the Directory
Create a new folder under `/modules` named after the AWS service (lowercase, use hyphens if needed).
```bash
mkdir modules/my-new-service
```

### 2. Required Files
Every module **MUST** contain these four files:

1.  **`main.tf`**: The core logic using standard AWS resources.
2.  **`variables.tf`**: All inputs with clear descriptions and types.
3.  **`outputs.tf`**: Essential outputs (ARNs, IDs, Endpoints).
4.  **`README.md`**: Technical documentation (use the template below).

### 3. Best Practices
- **Agnosticism**: Never hardcode project names or specific IDs. Use variables.
- **Tagging**: Always include a `tags` variable and merge it with default tags (`Name`, `Environment`, `ManagedBy`).
- **Descriptions**: Every variable and output must have a `description`.
- **Formatting**: Always run `terraform fmt` before committing.

---

## 📝 Documentation Template (README.md)

Each module directory must have a `README.md` with the following structure:

```markdown
# Module Name (e.g., S3 Bucket)

Brief description of what this module does.

## 🛠️ Resources Created
- List of AWS resources.

## 📥 Inputs
| Name | Description | Type | Required |
|---|---|---|---|
| `var_name` | What it does | `string` | **Yes** |

## 📤 Outputs
| Name | Description |
|---|---|
| `output_name` | What it represents |
```

---

remsoft
