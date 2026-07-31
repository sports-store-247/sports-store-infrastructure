# This account already has a GitHub Actions OIDC provider registered for
# token.actions.githubusercontent.com (shared across other projects on
# this account) — AWS only allows one per URL per account, so this looks
# it up instead of creating a new one.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:sports-store-247/*:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "sports-store-github-actions-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Project   = "CloudCart"
    ManagedBy = "Terraform"
    Owner     = "Sean"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions OIDC Authentication"
  value       = aws_iam_role.github_actions.arn
}
