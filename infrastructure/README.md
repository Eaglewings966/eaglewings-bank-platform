# Terraform Infrastructure as Code Guide

## Overview
This directory contains Terraform configurations for deploying the Eaglewings Bank Platform infrastructure on AWS.

## Architecture Components

### VPC Module (`modules/vpc/`)
- VPC with configurable CIDR block
- Public and Private subnets across multiple AZs
- Internet Gateway and NAT Gateway
- Route tables and security groups

### RDS Module (`modules/rds/`)
- PostgreSQL database instance
- Multi-AZ deployment option
- Automated backups and encryption
- Parameter groups and database configuration

### ECR Module (`modules/ecr/`)
- Elastic Container Registry repositories
- One repository per microservice
- Lifecycle policies for image retention
- Registry access credentials

### EKS Module (`modules/eks/`)
- EKS cluster creation
- Node groups with auto-scaling
- IAM roles and security groups
- OIDC provider for pod identity

## File Structure

```
infrastructure/
├── main.tf              # Main configuration and module calls
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
├── locals.tf            # Local values and computed variables
├── data.tf              # Data sources
├── terraform.tfvars     # Production values
├── dev.tfvars          # Development environment values
├── staging.tfvars      # Staging environment values
├── backend-setup.tf    # S3 and DynamoDB for state management
└── modules/
    ├── vpc/
    ├── rds/
    ├── ecr/
    └── eks/
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured with credentials
4. **kubectl** for Kubernetes management
5. **Helm** for package management

## Setup Instructions

### 1. Initialize Backend (One-time setup)

```bash
# Create S3 bucket and DynamoDB table for state
terraform apply -target=aws_s3_bucket.terraform_state \
                 -target=aws_dynamodb_table.terraform_locks \
                 -f backend-setup.tf
```

### 2. Configure Terraform Backend

Update `main.tf` with your S3 bucket and DynamoDB table names from the previous step.

```bash
# Initialize Terraform with remote backend
terraform init
```

### 3. Create Development Environment

```bash
# Plan deployment
terraform plan -var-file=dev.tfvars -out=dev.tfplan

# Apply configuration
terraform apply dev.tfplan
```

### 4. Create Staging Environment

```bash
# Plan deployment
terraform plan -var-file=staging.tfvars -out=staging.tfplan

# Apply configuration
terraform apply staging.tfplan
```

### 5. Create Production Environment

```bash
# Plan deployment
terraform plan -var-file=terraform.tfvars -out=prod.tfplan

# Review the plan carefully
terraform apply prod.tfplan
```

## Variable Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | us-east-1 |
| `project_name` | Project identifier | eaglewings-bank |
| `environment` | Environment name (dev/staging/prod) | prod |
| `vpc_cidr` | CIDR block for VPC | 10.0.0.0/16 |
| `rds_instance_class` | RDS instance type | db.t3.medium |
| `eks_instance_types` | EC2 instance types for EKS nodes | [t3.medium, t3.large] |
| `eks_desired_size` | Desired number of EKS nodes | 3 |

### Creating Custom Configurations

Create a new `.tfvars` file for your environment:

```bash
# Copy and modify existing configuration
cp terraform.tfvars custom.tfvars

# Edit custom.tfvars with your values
terraform plan -var-file=custom.tfvars
```

## Outputs

After successful deployment, retrieve outputs:

```bash
# All outputs
terraform output

# Specific output
terraform output eks_cluster_name

# JSON format
terraform output -json
```

Key outputs include:
- EKS cluster name and endpoint
- RDS database endpoint
- ECR registry URL
- VPC and subnet IDs
- IAM roles and security groups

## State Management

### Remote State
State is stored in S3 with DynamoDB locks to prevent concurrent modifications.

### Local State
For development, you can use local state:

```bash
# Remove remote backend configuration to use local state
# Comment out the backend block in main.tf
rm -rf .terraform
terraform init
```

### State Troubleshooting

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_eks_cluster.main

# Pull remote state locally
terraform state pull > terraform.tfstate

# Push local state to remote
terraform state push terraform.tfstate
```

## Common Operations

### View Current State

```bash
terraform show
```

### Update Specific Resource

```bash
terraform apply -target=aws_eks_cluster.main
```

### Destroy Infrastructure

```bash
# Development
terraform destroy -var-file=dev.tfvars

# Staging
terraform destroy -var-file=staging.tfvars

# Production (requires approval)
terraform destroy -var-file=terraform.tfvars
```

### Import Existing Resources

```bash
terraform import aws_eks_cluster.main <cluster-name>
```

## Troubleshooting

### Common Issues

#### Provider Issues
```bash
# Reinitialize providers
rm -rf .terraform
terraform init
```

#### State Lock
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

#### Module Errors
```bash
# Get modules
terraform get

# Upgrade modules
terraform get -upgrade
```

### Validation

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Check for best practices
tflint
```

## Environment-Specific Deployments

### Development (`dev.tfvars`)
- Single AZ
- Minimal resources (db.t3.micro, t3.small)
- 1 EKS node
- Skip final DB snapshot
- Short backup retention

### Staging (`staging.tfvars`)
- Multi-AZ deployment
- Medium resources (db.t3.small, t3.medium)
- 2 EKS nodes with 2-6 auto-scaling
- Standard backup retention (14 days)
- Regular snapshots

### Production (`terraform.tfvars`)
- Multi-AZ across 3 AZs
- Production resources (db.t3.medium, t3.large)
- 3 EKS nodes with 2-10 auto-scaling
- Long backup retention (30 days)
- Encryption enabled

## Security Best Practices

1. **Never commit** `.tfvars` files with sensitive data
2. **Use** AWS Secrets Manager or Parameter Store for secrets
3. **Enable** S3 versioning and encryption for state
4. **Apply** least privilege IAM policies
5. **Use** security groups to restrict access
6. **Enable** RDS encryption and backups
7. **Configure** VPC flow logs for monitoring
8. **Use** AWS KMS for encryption key management

## Monitoring and Logging

### CloudWatch Logs
- EKS cluster logs are enabled in the EKS module
- RDS enhanced monitoring available
- Application logs stored in CloudWatch

### Enable Additional Monitoring
```bash
# Add to your terraform variables
enable_monitoring = true
log_retention_days = 30
```

## Cost Optimization

1. Use auto-scaling for EKS nodes
2. Configure RDS to use reserved instances for production
3. Use spot instances for non-critical workloads
4. Monitor with AWS Cost Explorer
5. Set up billing alerts

## Maintenance

### Regular Tasks

- **Weekly**: Review CloudWatch logs and metrics
- **Monthly**: Update Terraform provider versions
- **Quarterly**: Review and update EC2 instance types
- **Annually**: Audit IAM permissions and security groups

### Backup Strategy

```bash
# Database backups (automated by RDS)
# Manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier eaglewings-bank-prod \
  --db-snapshot-identifier eaglewings-bank-prod-backup-$(date +%Y%m%d)
```

## References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform Best Practices](https://www.terraform.io/docs/language)
