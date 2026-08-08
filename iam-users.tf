locals {
  students_config = yamldecode(file("${path.module}/students.yaml"))
  students_map    = { for s in local.students_config.students : s.username => s }
}

resource "aws_iam_user" "students" {
  for_each = local.students_map
  name     = each.value.username
  tags     = { Project = "CloudCart" }
}

resource "aws_iam_user_login_profile" "students" {
  for_each                = aws_iam_user.students
  user                    = each.value.name
  password_reset_required = true
  lifecycle { ignore_changes = all }
}

resource "aws_iam_group" "devops_students" {
  name = "cloudcart-devops-team"
}

resource "aws_iam_group_membership" "students" {
  name  = "cloudcart-students-membership"
  users = [for u in aws_iam_user.students : u.name]
  group = aws_iam_group.devops_students.name
}

resource "aws_eks_access_entry" "students" {
  for_each      = aws_iam_user.students
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "students" {
  for_each      = aws_eks_access_entry.students
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_policy" "ecr_access" {
  name   = "cloudcart-ecr-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage", "ecr:PutImage", "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart", "ecr:CompleteLayerUpload",
        ]
        Resource = [for repo in aws_ecr_repository.services : repo.arn]
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "ecr_access" {
  group      = aws_iam_group.devops_students.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

resource "aws_iam_group_policy_attachment" "cloudwatch_access" {
  group      = aws_iam_group.devops_students.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

output "student_passwords" {
  description = "Initial passwords for team members — distribute securely"
  value       = { for k, v in aws_iam_user_login_profile.students : k => v.password }
  sensitive   = true
}

resource "aws_iam_role" "cross_account_cloudwatch_read" {
  name = "CrossAccountCloudWatchReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::364424789106:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cross_account_cloudwatch_read" {
  role       = aws_iam_role.cross_account_cloudwatch_read.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
