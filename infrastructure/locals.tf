# Local variables for common configuration
locals {
  # Common tags to be applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }

  # EKS Configuration
  eks_cluster_name = "${var.project_name}-${var.environment}-eks"
  
  # RDS Configuration
  rds_identifier = "${var.project_name}-${var.environment}-postgres"
  
  # ECR Configuration
  ecr_namespace = "${var.project_name}-${var.environment}"

  # Service names
  services = [
    "auth-service",
    "account-service",
    "transaction-service",
    "payment-service",
    "notification-service",
    "analytics-service",
    "frontend"
  ]

  # Network Configuration
  vpc_name = "${var.project_name}-${var.environment}-vpc"
  
  # Kubernetes Namespace
  k8s_namespace = var.environment == "prod" ? "production" : var.environment
}
