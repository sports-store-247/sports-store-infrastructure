#!/usr/bin/env bash
set -e

echo "============================================================"
echo "🛑 1. Cleaning Up ArgoCD Applications & Ingress Resources"
echo "============================================================"
kubectl delete application cloudcart -n argocd --ignore-not-found=true
kubectl delete ingress -A --all --ignore-not-found=true

echo "============================================================"
echo "⏳ 2. Waiting 2 Minutes for AWS Load Balancers to Terminate"
echo "============================================================"
echo "This prevents AWS Load Balancers from blocking Terraform VPC teardown..."
sleep 120

echo "============================================================"
echo "💥 3. Running Terraform Destroy"
echo "============================================================"
terraform destroy -auto-approve

echo "=== Teardown Complete! All resources destroyed safely. ==="
