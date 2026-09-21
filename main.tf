terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. AWS Organizations & Organizational Units
module "organization" {
  source = "./modules/organization"

  root_email             = var.root_email
  create_member_accounts = var.create_member_accounts
  security_ou_name       = "Security"
  infrastructure_ou_name = "Infrastructure"
  workloads_ou_name      = "Workloads"

  # Core Accounts
  log_archive_email      = var.log_archive_email
  security_tooling_email = var.security_tooling_email
  shared_services_email  = var.shared_services_email
  prod_workload_email    = var.prod_workload_email
  dev_workload_email     = var.dev_workload_email
}

# 2. Service Control Policies (Guardrails)
module "scp" {
  source = "./modules/scp"

  depends_on = [module.organization]

  target_ou_ids = [
    module.organization.security_ou_id,
    module.organization.infrastructure_ou_id,
    module.organization.workloads_ou_id
  ]

  allowed_regions = var.allowed_regions
}