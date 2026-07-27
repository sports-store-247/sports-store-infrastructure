variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "sports-store-cluster"
}

variable "cluster_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 Instance type for EKS nodes (t3.small = 2GB RAM per node, optimal cost/perf balance)"
  type        = string
  default     = "t3.small"
}

variable "desired_nodes" {
  description = "Desired number of nodes in EKS (Set to 2 for minimal AWS cost)"
  type        = number
  default     = 2
}

variable "tfc_organization" {
  description = "Terraform Cloud Organization"
  type        = string
  default     = ""
}

variable "tfc_workspace" {
  description = "Terraform Cloud Workspace"
  type        = string
  default     = "sports-store-infrastructure"
}
