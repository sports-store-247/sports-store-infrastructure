# Sean's Infrastructure Master Playbook (Infrastructure Lead)

This playbook outlines **Sean's role as the Infrastructure & Platform Lead**. You are responsible for provisioning the **entire AWS Cloud Infrastructure**, EKS cluster, AWS Load Balancer Controller, ECR registries, GitHub Actions OIDC Authentication, ArgoCD GitOps engine, and Prometheus/Grafana Observability stack using **Terraform**.

---

## 🏗️ What Sean Built & Provisioned (`sports-store-infrastructure`)

Directory: `/Users/shon/Final-Project/sports-store-infrastructure`

### 1. Core Modules Included
- **`vpc.tf`**: AWS VPC (`terraform-aws-modules/vpc/aws`) with Public/Private subnets, NAT Gateways, and EKS tagging.
- **`eks.tf`**: AWS EKS (`terraform-aws-modules/eks/aws` v20.0) with Managed Node Group, `vpc-cni` prefix delegation, CoreDNS, kube-proxy, and EBS CSI driver.
- **`alb-controller.tf` & `alb-controller-policy.json`**: AWS Load Balancer Controller IRSA IAM policy + Helm release for ALB Ingress.
- **`ecr.tf`**: 7 ECR container registries (`sports-store-auth-service`, `sports-store-catalog-service`, `sports-store-cart-service`, `sports-store-order-service`, `sports-store-payment-service`, `sports-store-gateway`, `sports-store-frontend`).
- **`github-oidc.tf`**: OIDC Provider + IAM Role (`sports-store-github-actions-ecr-role`) allowing keyless GitHub Actions pushes to ECR across all `sports-store-247/*` repos.
- **`argocd.tf`**: ArgoCD GitOps engine deployed via Helm onto EKS.
- **`prometheus.tf`**: `kube-prometheus-stack` (Grafana & Prometheus dashboards) deployed via Helm.
- **`secrets.tf` & `pod-identity.tf`**: AWS Secrets Manager + EKS Pod Identity / IRSA (Required Extension).
- **`iam-users.tf` & `students.yaml`**: Team IAM users (`sean`, `maxim`, `david`, `rossman`) + EKS Access Entries (`AmazonEKSAdminPolicy`).

---

## 🚀 How Sean Executes the Infrastructure

### Step 1: Initialize & Plan Terraform
```bash
cd /Users/shon/Final-Project/sports-store-infrastructure

# Initialize providers & modules
terraform init

# Validate configuration
terraform validate

# Preview infrastructure plan
terraform plan
```

### Step 2: Provision Infrastructure on AWS
```bash
terraform apply -auto-approve
```

### Step 3: Connect `kubectl` to your EKS Cluster
```bash
aws eks update-kubeconfig --region us-east-1 --name sports-store-cluster
```

---

## 🔬 Grading Criteria Fulfilled by Sean's Infrastructure Code

- [x] **Public Terraform Modules**: Uses official `terraform-aws-modules/vpc/aws` & `terraform-aws-modules/eks/aws`.
- [x] **No Static AWS Keys**: Keyless OIDC authentication configured in `github-oidc.tf`.
- [x] **ALB Ingress**: AWS Load Balancer Controller with IRSA configured in `alb-controller.tf`.
- [x] **EBS Dynamic Provisioning**: EBS CSI driver add-on enabled in `eks.tf`.
- [x] **GitOps Engine**: ArgoCD deployed via Helm in `argocd.tf`.
- [x] **Observability**: Prometheus + Grafana stack deployed via Helm in `prometheus.tf`.
- [x] **Required Extension**: AWS Secrets Manager + EKS Pod Identity configured in `secrets.tf` and `pod-identity.tf`.
