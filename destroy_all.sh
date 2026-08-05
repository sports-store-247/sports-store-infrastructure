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
echo "💥 3. Cleanly Uninstalling Helm Releases (ArgoCD & Prometheus)"
echo "============================================================"
# Destroy Helm releases first so Terraform Cloud doesn't hang!
terraform destroy -target=helm_release.argocd -target=helm_release.kube-prometheus-stack -target=helm_release.alb_controller -auto-approve

echo "============================================================"
echo "💥 4. Destroying Expensive Compute (EKS & VPC)"
echo "============================================================"
# ONLY destroy the expensive compute resources. Preserve ECR and IAM!
terraform destroy -target=module.eks -target=module.vpc -auto-approve

echo "=== Teardown Complete! Compute destroyed safely. ==="
