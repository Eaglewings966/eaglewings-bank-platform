# Deployment Guide for EAGLEWINGS Bank Platform

## Prerequisites

- AWS Account with appropriate permissions
- Terraform 1.x installed
- kubectl 1.24+ installed
- Docker installed
- Git
- AWS CLI configured

## Infrastructure Deployment

### 1. Initialize Terraform

```bash
cd infrastructure
terraform init
```

This will:
- Create S3 bucket for state management
- Create DynamoDB table for state locking
- Initialize Terraform modules

### 2. Review Terraform Plan

```bash
terraform plan -var-file="terraform.tfvars"
```

This will show you all the resources that will be created.

### 3. Apply Terraform Configuration

```bash
terraform apply -var-file="terraform.tfvars"
```

This will create:
- VPC with public and private subnets
- RDS PostgreSQL database
- EKS Cluster with node groups
- ECR repositories for Docker images

### 4. Get Outputs

```bash
terraform output
```

This will display important information like:
- EKS Cluster endpoint
- RDS database endpoint
- ECR repository URLs

## Local Development Setup

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd eaglewings-bank-platform
```

### 2. Start Services with Docker Compose

```bash
docker-compose up -d
```

This will start:
- PostgreSQL database on port 5432
- Auth Service on port 3001
- Account Service on port 3002
- Transaction Service on port 3003
- Payment Service on port 3004
- Notification Service on port 3005
- Analytics Service on port 3006
- Frontend on port 3000

### 3. Access Services

- **Frontend**: http://localhost:3000
- **Auth Service**: http://localhost:3001
- **Account Service**: http://localhost:3002
- **Postgres**: postgresql://postgres:postgres123@localhost:5432/eaglewings_db

## Deploying to EKS

### 1. Build and Push Docker Images

```bash
./scripts/build-and-push.sh
```

### 2. Create kubeconfig

```bash
aws eks update-kubeconfig --region us-east-1 --name eaglewings-bank-eks-cluster
```

### 3. Deploy Services to Kubernetes

```bash
kubectl apply -f kubernetes/auth-service-deployment.yaml
kubectl apply -f kubernetes/account-service-deployment.yaml
kubectl apply -f kubernetes/ingress.yaml
```

### 4. Verify Deployment

```bash
kubectl get pods
kubectl get services
kubectl get ingress
```

## Environment Variables

### Frontend
```
REACT_APP_API_URL=https://api.eaglewings-bank.com
```

### Backend Services
```
DATABASE_URL=postgresql://user:password@host:5432/eaglewings_db
JWT_SECRET=your-secret-key
NODE_ENV=production
LOG_LEVEL=info
```

## CI/CD Pipeline

The repository includes GitHub Actions workflows for:
- Automated testing on push/PR
- Building Docker images
- Pushing to ECR
- Deploying to EKS

### Required GitHub Secrets

- `AWS_ACCOUNT_ID`: Your AWS account ID
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `KUBECONFIG`: Base64 encoded kubeconfig file

## Monitoring

### CloudWatch
- Logs are automatically sent to CloudWatch
- Metrics for EKS, RDS, and other services

### Application Insights
- Monitor application performance
- Track errors and anomalies

## Troubleshooting

### Services not starting
```bash
# Check logs
kubectl logs <pod-name>

# Check pod status
kubectl describe pod <pod-name>

# Check service
kubectl describe service <service-name>
```

### Database connection issues
```bash
# Check RDS endpoint
aws rds describe-db-instances --query 'DBInstances[0].Endpoint'

# Test connection
psql -h <endpoint> -U postgres -d eaglewings_db
```

### EKS cluster issues
```bash
# Get cluster info
aws eks describe-cluster --name eaglewings-bank-eks-cluster

# Check node groups
aws eks describe-nodegroup --cluster-name eaglewings-bank-eks-cluster --nodegroup-name eaglewings-bank-node-group
```

## Cleanup

To destroy all resources:

```bash
cd infrastructure
terraform destroy -var-file="terraform.tfvars"
```

**WARNING**: This will delete all resources including the RDS database.

## Support

For issues or questions, please create an issue in the GitHub repository.
