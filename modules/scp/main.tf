# SCP 1: Deny Leave Organization
resource "aws_organizations_policy" "deny_leave_org" {
  name        = "DenyLeaveOrganization"
  description = "Prevents member accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "PreventLeaveOrg"
      Effect   = "Deny"
      Action   = "organizations:LeaveOrganization"
      Resource = "*"
    }]
  })
}

# SCP 2: Enforce Region Restriction
resource "aws_organizations_policy" "region_restriction" {
  name        = "RegionRestrictionPolicy"
  description = "Denies access to unapproved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyUnapprovedRegions"
      Effect = "Deny"
      NotAction = [
        "iam:*",
        "organizations:*",
        "route53:*",
        "cloudfront:*",
        "sts:*",
        "support:*"
      ]
      Resource = "*"
      Condition = {
        StringNotEquals = {
          "aws:RequestedRegion" = var.allowed_regions
        }
      }
    }]
  })
}

# SCP 3: Protect Security Services (GuardDuty, Config, CloudTrail)
resource "aws_organizations_policy" "protect_security_services" {
  name        = "ProtectSecurityServices"
  description = "Prevents disabling or deleting core security tooling"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DisableSecurityTools"
      Effect = "Deny"
      Action = [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "guardduty:DeleteDetector",
        "guardduty:DisassociateFromMasterAccount",
        "config:DeleteDeliveryChannel",
        "config:StopConfigurationRecorder"
      ]
      Resource = "*"
    }]
  })
}

# Attach SCPs to OUs
resource "aws_organizations_policy_attachment" "attach_leave_org" {
  count     = length(var.target_ou_ids)
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = var.target_ou_ids[count.index]
}

resource "aws_organizations_policy_attachment" "attach_region_restrict" {
  count     = length(var.target_ou_ids)
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = var.target_ou_ids[count.index]
}

resource "aws_organizations_policy_attachment" "attach_protect_security" {
  count     = length(var.target_ou_ids)
  policy_id = aws_organizations_policy.protect_security_services.id
  target_id = var.target_ou_ids[count.index]
}