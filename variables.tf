variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Primary AWS deployment region"
}

variable "allowed_regions" {
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
  description = "List of approved AWS regions enforced by SCP"
}

variable "create_member_accounts" {
  type        = bool
  default     = false
  description = "Create the four member accounts. Set true only when each account has a unique email address."
}

variable "root_email" {
  type        = string
  sensitive   = true
  description = "Email address for the management account, supplied outside version control"
}

variable "log_archive_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Log Archive account, supplied outside version control"
}

variable "security_tooling_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Security Tooling account, supplied outside version control"
}

variable "shared_services_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Shared Services account, supplied outside version control"
}

variable "prod_workload_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Production Workload account, supplied outside version control"
}

variable "dev_workload_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Development Workload account, supplied outside version control"
}