# 1. Set the KMS Key ARN Secret
gh secret set KMS_KEY_ARN --body "$(terraform output -raw kms_key_arn)"

# 2. Set the IAM Execution Role ARN Secret
gh secret set AWS_ROLE_TO_ASSUME --body "$(terraform output -raw github_actions_role_arn)"