# aws-secure-multi-account

## Terraform backend bootstrap

The S3 backend must exist before the root configuration can be initialized. From
the repository root, create it with the bootstrap configuration first:

```text
terraform -chdir=modules/scp/bootstrap init
terraform -chdir=modules/scp/bootstrap apply
terraform init -reconfigure
```

The root configuration uses the `org-tfstate-landing-zone-management` bucket
and stores state at `landing-zone/terraform.tfstate`.

## Account email variables

Account emails are sensitive Terraform variables and must not be committed.
Copy `terraform.tfvars.example` to `terraform.tfvars` and replace the example
values with unique email addresses or supported aliases. The real
`terraform.tfvars` file is ignored by Git.

AWS does not allow an account to be created with an email address that already
belongs to another AWS account. Existing accounts must be invited into the
organization and imported into Terraform instead of being recreated.

For training without creating member accounts, leave `create_member_accounts = false`.
Set it to `true` only when every member account has a different, unused email address.