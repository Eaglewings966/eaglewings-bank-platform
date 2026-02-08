# Data sources for existing AWS resources and computations

# Current AWS Account ID
data "aws_caller_identity" "current" {}

# Current AWS Region
data "aws_region" "current" {}

# Availability zones in current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the kubeconfig for EKS cluster
data "aws_eks_cluster" "main" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

# Get the kubeconfig certificate authority for EKS cluster
data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}
