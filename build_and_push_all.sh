#!/bin/bash
set -e

ACCOUNT_ID="765858872029"
REGION="us-east-1"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
REPOS_DIR="/Users/shon/Final-Project/Repos"

echo "============================================================"
echo "🔐 1. Authenticating Docker to AWS ECR"
echo "============================================================"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REGISTRY}

SERVICES=(
  "sports-store-auth-service"
  "sports-store-catalog-service"
  "sports-store-cart-service"
  "sports-store-order-service"
  "sports-store-payment-service"
  "sports-store-gateway"
  "sports-store-frontend"
)

for SERVICE in "${SERVICES[@]}"; do
  echo "============================================================"
  echo "📦 Building & Pushing: ${SERVICE}"
  echo "============================================================"
  SERVICE_DIR="${REPOS_DIR}/${SERVICE}"
  if [ -d "${SERVICE_DIR}" ]; then
    cd "${SERVICE_DIR}"
    docker build --platform linux/amd64 -t "${REGISTRY}/${SERVICE}:latest" .
    docker push "${REGISTRY}/${SERVICE}:latest"
    echo "✅ Successfully pushed ${SERVICE}:latest to ECR"
  else
    echo "⚠️ Warning: Directory ${SERVICE_DIR} not found, skipping..."
  fi
done

echo "============================================================"
echo "🎉 ALL MICROSERVICES BUILT & PUSHED TO ECR SUCCESSFULLY!"
echo "============================================================"
