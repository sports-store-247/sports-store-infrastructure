# sports-store-infrastructure

Terraform IaC for the Sports Store platform's cloud infrastructure (EKS cluster,
networking, and related AWS resources). Not yet written — this repo is a
placeholder until the infrastructure milestone begins.

## Branching convention

- `feature/<short-description>` — new functionality
- `bugfix/<short-description>` — non-urgent fixes
- `hotfix/<short-description>` — urgent production fixes

All changes land on `main` via pull request with at least 1 approval (enforced by repository ruleset).

## Required Extension Declaration

**Required Extension Implemented**: AWS Secrets Manager + EKS Pod Identity / IRSA.
- We have configured AWS Secrets Manager to securely store secrets.
- We have integrated this with EKS Pod Identity using IRSA (IAM Roles for Service Accounts).
- ExternalSecrets (ESO) connects to Secrets Manager and natively syncs credentials directly into Kubernetes Secrets.
