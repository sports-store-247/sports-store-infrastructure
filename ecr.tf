locals {
  services = [
    "sports-store-auth-service",
    "sports-store-catalog-service",
    "sports-store-cart-service",
    "sports-store-order-service",
    "sports-store-payment-service",
    "sports-store-gateway",
    "sports-store-frontend"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(local.services)
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project   = "CloudCart"
    ManagedBy = "Terraform"
    Owner     = "Sean"
  }
}

output "ecr_repository_urls" {
  description = "Map of ECR Repository URLs for CI/CD"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}
