variable "root_email" {
  type        = string
  sensitive   = true
  description = "Email address associated with the AWS Organizations management account"
}

variable "create_member_accounts" {
  type        = bool
  description = "Whether to create the four member accounts"
}

variable "security_ou_name" {
  type        = string
  default     = "Security"
  description = "Name of the Security Organizational Unit"
}

variable "infrastructure_ou_name" {
  type        = string
  default     = "Infrastructure"
  description = "Name of the Infrastructure Organizational Unit"
}

variable "workloads_ou_name" {
  type        = string
  default     = "Workloads"
  description = "Name of the Workloads Organizational Unit"
}

variable "log_archive_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Log Archive account"
}

variable "security_tooling_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Security Tooling account"
}

variable "shared_services_email" {
  type        = string
  sensitive   = true
  description = "Email address for the Shared Services account"
}

variable "prod_workload_email" {
  type        = string
  sensitive   = true
  description = "Email address for the App Production account"
}

variable "dev_workload_email" {
  type        = string
  sensitive   = true
  description = "Email address for the App Development account"
}