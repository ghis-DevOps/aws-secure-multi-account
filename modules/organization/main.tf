resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "sso.amazonaws.com"
  ]
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
  feature_set          = "ALL"
}

# Organizational Units (OUs)
resource "aws_organizations_organizational_unit" "security" {
  name      = var.security_ou_name
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = var.infrastructure_ou_name
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = var.workloads_ou_name
  parent_id = aws_organizations_organization.main.roots[0].id
}

# Child OUs for Workloads
resource "aws_organizations_organizational_unit" "prod" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "non_prod" {
  name      = "Non-Production"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# Security Core Accounts
resource "aws_organizations_account" "log_archive" {
  count     = var.create_member_accounts ? 1 : 0
  name      = "Log-Archive"
  email     = var.log_archive_email
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "security_tooling" {
  count     = var.create_member_accounts ? 1 : 0
  name      = "Security-Tooling"
  email     = var.security_tooling_email
  parent_id = aws_organizations_organizational_unit.security.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

# Shared Services Account
resource "aws_organizations_account" "shared_services" {
  name      = "Shared-Services"
  email     = var.shared_services_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  lifecycle {
    ignore_changes = [role_name, email]
  }
}

# Workload Accounts
resource "aws_organizations_account" "prod_app" {
  count     = var.create_member_accounts ? 1 : 0
  name      = "App-Production"
  email     = var.prod_workload_email
  parent_id = aws_organizations_organizational_unit.prod.id

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "dev_app" {
  count     = var.create_member_accounts ? 1 : 0
  name      = "App-Development"
  email     = var.dev_workload_email
  parent_id = aws_organizations_organizational_unit.non_prod.id

  lifecycle {
    ignore_changes = [role_name]
  }
}