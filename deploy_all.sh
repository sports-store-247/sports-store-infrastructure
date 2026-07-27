#!/usr/bin/env bash
set -e

CLUSTER_NAME="sports-store-cluster"
REGION="us-east-1"
ARGOCD_APP_FILE="argocd-app.yaml"

echo "============================================================"
echo "🚀 1. Provisioning Cloud Infrastructure via Terraform"
echo "============================================================"
terraform init
terraform apply -auto-approve

echo "============================================================"
echo "🔑 2. Updating Local kubectl Credentials"
echo "============================================================"
aws eks update-kubeconfig --region "${REGION}" --name "${CLUSTER_NAME}"

echo "============================================================"
echo "🔐 3. Setting Up AWS Secrets Manager (MongoDB Secret)"
echo "============================================================"
# Check if secret exists, if not create it, else update value
if aws secretsmanager describe-secret --secret-id "cloudcart/mongo_uri" --region "${REGION}" &>/dev/null; then
    aws secretsmanager put-secret-value \
      --region "${REGION}" \
      --secret-id "cloudcart/mongo_uri" \
      --secret-string "mongodb://mongo:27017/cloudcart" \
      --no-cli-pager
else
    aws secretsmanager create-secret \
      --region "${REGION}" \
      --name "cloudcart/mongo_uri" \
      --secret-string "mongodb://mongo:27017/cloudcart" \
      --no-cli-pager
fi

echo "============================================================"
echo "📦 4. Applying ArgoCD Application GitOps Manifest"
echo "============================================================"
if [ -f "${ARGOCD_APP_FILE}" ]; then
  kubectl apply -f "${ARGOCD_APP_FILE}"
else
  echo "Warning: ${ARGOCD_APP_FILE} not found. Skipping ArgoCD application apply."
fi

echo "============================================================"
echo "🔍 5. Fetching Cluster Endpoints & Credentials"
echo "============================================================"
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "N/A")
ALB_URL=$(kubectl get ingress -A -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Provisioning (Check in 1-2 mins)")

echo ""
echo "============================================================"
echo "🎉 CLOUDCART DEPLOYMENT COMPLETE!"
echo "============================================================"
echo "EKS Cluster Name : ${CLUSTER_NAME}"
echo "ALB Hostname     : ${ALB_URL}"
echo "ArgoCD Dashboard : http://${ALB_URL}/argocd/"
echo "ArgoCD Login     : admin / ${ARGOCD_PASS}"
echo "Grafana Dashboard: http://${ALB_URL}/grafana/"
echo "Grafana Login    : admin / prom-operator"
echo "Live App URL     : http://${ALB_URL}/"
echo "============================================================"
