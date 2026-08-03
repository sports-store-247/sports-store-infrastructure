# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "mongodb_uri" {
  name                    = "sports-store/production"
  description             = "MongoDB URIs and JWT secret for Sports Store"
  tags                    = { Project = "SportsStore" }
}

resource "aws_secretsmanager_secret_version" "sports_store_secrets_version" {
  secret_id     = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = jsonencode({
    "JWT_SECRET"          = "sports-store-local-jwt-secret",
    "MONGO_ROOT_USERNAME" = "root",
    "MONGO_ROOT_PASSWORD" = "sports-store-local-password",
    "AUTH_MONGO_URI"      = "mongodb://root:sports-store-local-password@cloudcart-mongodb.cloudcart.svc.cluster.local:27017/auth?authSource=admin",
    "CATALOG_MONGO_URI"   = "mongodb://root:sports-store-local-password@cloudcart-mongodb.cloudcart.svc.cluster.local:27017/catalog?authSource=admin",
    "CART_MONGO_URI"      = "mongodb://root:sports-store-local-password@cloudcart-mongodb.cloudcart.svc.cluster.local:27017/cart?authSource=admin",
    "ORDER_MONGO_URI"     = "mongodb://root:sports-store-local-password@cloudcart-mongodb.cloudcart.svc.cluster.local:27017/order?authSource=admin",
    "PAYMENT_MONGO_URI"   = "mongodb://root:sports-store-local-password@cloudcart-mongodb.cloudcart.svc.cluster.local:27017/payment?authSource=admin"
  })
}

# IAM Policy to read the secret
resource "aws_iam_policy" "external_secrets" {
  name        = "SportsStoreExternalSecretsPolicy"
  description = "Allow External Secrets Operator to read from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = [aws_secretsmanager_secret.mongodb_uri.arn]
      }
    ]
  })
}

# IRSA Role for the External Secrets Operator
module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "sports-store-external-secrets-role"

  attach_external_secrets_policy = false
  role_policy_arns = {
    secrets = aws_iam_policy.external_secrets.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["sports-store:app-secrets-sa"]
    }
  }

  tags = { Project = "SportsStore" }
}

# Helm Release for External Secrets Operator
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.9.13"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_secrets_irsa_role.iam_role_arn
  }
}
