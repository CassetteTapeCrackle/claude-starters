# Terraform project rules

Framework: __FRAMEWORK__ — locked. Do not introduce alternative frameworks without explicit approval.

## Structure & deps
- Pin Terraform and provider versions (required_version, required_providers). Commit .terraform.lock.hcl.
- Remote state (backend) with locking; never commit state or secrets.
- Reusable modules under modules/; environments compose them. One responsibility per module.

## Code
- `terraform fmt` + `terraform validate` + `tflint` clean before commit.
- Variables typed with descriptions; outputs documented. No hardcoded secrets — use vars/secret managers.
- Least-privilege IAM; tag resources consistently; greppable names.

## Tests / checks
- `terraform plan` reviewed before apply. Optionally terraform test / terratest for modules.

## Commands
- Format: terraform fmt -recursive   ·   Validate: terraform validate
- Lint: tflint   ·   Plan: terraform plan
