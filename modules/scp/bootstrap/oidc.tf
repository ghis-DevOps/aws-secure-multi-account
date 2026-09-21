variable "github_org" {
  type        = string
  description = "Your GitHub Organization or Username"
  default     = "your-github-org" # Replace with your actual GitHub Org/User
}

variable "github_repo" {
  type        = string
  description = "Your GitHub Repository Name"
  default     = "aws-landing-zone" # Replace with your actual repo name
}

# 1. Register GitHub as an OpenID Connect (OIDC) Identity Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. Define OIDC Trust Policy
data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict execution strictly to your specific repository and main branch
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"]
    }
  }
}

# 3. Create the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_runner" {
  name               = "github-actions-terraform-runner-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 4. Define Permissions Policy for S3 Backend, DynamoDB, KMS, and Cross-Account Assumption
data "aws_iam_policy_document" "github_actions_permissions" {
  # Bucket-level permissions (fixes 403 Forbidden errors)
  statement {
    sid    = "S3StateBucketPermissions"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  # Object-level permissions
  statement {
    sid    = "S3StateObjectPermissions"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.terraform_state.arn}/*"]
  }

  # DynamoDB Lock Table access
  statement {
    sid    = "DynamoDBLockPermissions"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.terraform_locks.arn]
  }

  # KMS Key access for state decryption/encryption
  statement {
    sid    = "KMSKeyAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.terraform_state_key.arn]
  }

  # Cross-account role assumption for child account deployments
  statement {
    sid       = "AssumeCrossAccountRoles"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/OrganizationAccountAccessRole"]
  }
}

# 5. Create and Attach Policy
resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-terraform-policy-${var.environment}"
  description = "Permissions for GitHub Actions to manage state and deploy landing zone"
  policy      = data.aws_iam_policy_document.github_actions_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_runner.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# 6. Outputs
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_runner.arn
  description = "ARN of the IAM Role to configure in your GitHub Actions workflow"
}