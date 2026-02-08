# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_ip
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS Database Port"
  value       = module.rds.db_port
}

output "rds_database_name" {
  description = "RDS Database Name"
  value       = module.rds.db_name
}

output "rds_master_username" {
  description = "RDS Master Username"
  value       = module.rds.db_master_username
  sensitive   = true
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = module.rds.security_group_id
}

# ECR Outputs
output "ecr_registry_url" {
  description = "ECR Registry URL"
  value       = module.ecr.registry_url
}

output "ecr_repository_urls" {
  description = "ECR Repository URLs by service"
  value       = module.ecr.repository_urls
}

output "ecr_auth_token" {
  description = "ECR Authorization Token"
  value       = module.ecr.auth_token
  sensitive   = true
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "EKS Cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "EKS Cluster CA Certificate"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_id" {
  description = "EKS Node Group ID"
  value       = module.eks.node_group_id
}

output "eks_iam_role_arn" {
  description = "EKS IAM Role ARN"
  value       = module.eks.iam_role_arn
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

# Local Kubeconfig Command
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Summary
output "environment_summary" {
  description = "Environment and deployment summary"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    aws_region      = var.aws_region
    eks_cluster     = module.eks.cluster_name
    database_host   = module.rds.db_instance_endpoint
    registry_url    = module.ecr.registry_url
  }
}
