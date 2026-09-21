output "org_id" {
  value       = aws_organizations_organization.main.id
  description = "The AWS Organizations organization ID"
}

output "security_ou_id" {
  value       = aws_organizations_organizational_unit.security.id
  description = "The Security organizational unit ID"
}

output "infrastructure_ou_id" {
  value       = aws_organizations_organizational_unit.infrastructure.id
  description = "The Infrastructure organizational unit ID"
}

output "workloads_ou_id" {
  value       = aws_organizations_organizational_unit.workloads.id
  description = "The Workloads organizational unit ID"
}

output "log_archive_account_id" {
  value       = var.create_member_accounts ? aws_organizations_account.log_archive[0].id : null
  description = "The Log Archive account ID"
}

output "security_tooling_account_id" {
  value       = var.create_member_accounts ? aws_organizations_account.security_tooling[0].id : null
  description = "The Security Tooling account ID"
}

output "shared_services_account_id" {
  value       = aws_organizations_account.shared_services.id
  description = "The Shared Services account ID"
}

output "prod_workload_account_id" {
  value       = var.create_member_accounts ? aws_organizations_account.prod_app[0].id : null
  description = "The Production workload account ID"
}

output "dev_workload_account_id" {
  value       = var.create_member_accounts ? aws_organizations_account.dev_app[0].id : null
  description = "The Development workload account ID"
}