terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "eaglewings-bank-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "eaglewings-bank-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EAGLEWINGS Bank Platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  aws_region         = var.aws_region
  availability_zones = var.availability_zones
}

# RDS PostgreSQL Module
module "rds" {
  source = "./modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  allocated_storage       = var.rds_allocated_storage
  engine_version          = var.postgres_version
  instance_class          = var.rds_instance_class
  database_name           = var.database_name
  master_username         = var.db_master_username
  multi_az                = var.rds_multi_az
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  skip_final_snapshot     = var.rds_skip_final_snapshot
  backup_retention_days   = var.rds_backup_retention_days
  enable_encryption       = var.rds_enable_encryption
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  
  repositories = [
    "auth-service",
    "account-service",
    "transaction-service",
    "payment-service",
    "notification-service",
    "analytics-service",
    "frontend"
  ]
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name           = var.project_name
  environment            = var.environment
  cluster_version        = var.eks_cluster_version
  instance_types         = var.eks_instance_types
  desired_size           = var.eks_desired_size
  min_size               = var.eks_min_size
  max_size               = var.eks_max_size
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  rds_endpoint           = module.rds.db_instance_endpoint
  rds_database_name      = module.rds.db_name
  rds_master_username    = module.rds.db_master_username
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "ecr_repositories" {
  description = "ECR Repository URLs"
  value       = module.ecr.repository_urls
}
