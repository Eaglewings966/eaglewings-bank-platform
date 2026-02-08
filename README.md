# EAGLEWINGS BANK PLATFORM

A comprehensive three-tier cloud-native banking application built with Node.js microservices, React frontend, and AWS infrastructure on EKS.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (React)                      │
│              Deployed on AWS CloudFront + S3             │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│           API Gateway / Application Load Balancer       │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│            Amazon EKS (Kubernetes Cluster)              │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Microservices (Node.js)                        │   │
│  │  • Auth Service                                 │   │
│  │  • Account Service                              │   │
│  │  • Transaction Service                          │   │
│  │  • Payment Service                              │   │
│  │  • Notification Service                         │   │
│  │  • Analytics Service                            │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│    Amazon RDS PostgreSQL Database                       │
│    • Multi-AZ Deployment                                │
│    • Automated Backups                                  │
└─────────────────────────────────────────────────────────┘
```

## Project Structure

```
eaglewings-bank-platform/
├── infrastructure/           # Terraform IaC
│   ├── modules/
│   │   ├── vpc/             # VPC, Subnets, NAT Gateway
│   │   ├── rds/             # PostgreSQL Database
│   │   ├── eks/             # EKS Cluster & Node Groups
│   │   └── ecr/             # Elastic Container Registry
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── backend/                  # Node.js Microservices
│   ├── services/
│   │   ├── auth-service/     # JWT Authentication
│   │   ├── account-service/  # Account Management
│   │   ├── transaction-service/  # Transaction Processing
│   │   ├── payment-service/  # Payment Gateway Integration
│   │   ├── notification-service/  # Email & SMS Notifications
│   │   └── analytics-service/   # Reporting & Analytics
│   ├── shared/               # Common utilities, middleware
│   └── package.json
├── frontend/                 # React Application
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── App.js
│   └── package.json
├── docker/                   # Docker configurations
├── kubernetes/               # K8s manifests (Helm charts)
└── docker-compose.yaml      # Local development setup
```

## Features

- **Microservices Architecture**: Independent, scalable services for different business domains
- **Cloud-Native**: Deployed on AWS EKS with auto-scaling
- **Security**: JWT authentication, encrypted connections, RBAC
- **Database**: PostgreSQL with high availability
- **CI/CD**: GitOps with ArgoCD for automated deployments
- **Monitoring**: CloudWatch integration
- **API Documentation**: Swagger/OpenAPI for all services

## Microservices

### 1. **Auth Service** (Port 3001)
- User registration and login
- JWT token generation and validation
- Password encryption and reset
- Role-based access control (RBAC)

### 2. **Account Service** (Port 3002)
- Account creation and management
- Account type management (Savings, Checking, etc.)
- Account balance tracking
- Account closure

### 3. **Transaction Service** (Port 3003)
- Transaction recording
- Transaction history and filtering
- Transfer between accounts
- Transaction status tracking

### 4. **Payment Service** (Port 3004)
- Payment processing
- Third-party payment gateway integration
- Invoice generation
- Payment reconciliation

### 5. **Notification Service** (Port 3005)
- Email notifications
- SMS notifications
- Push notifications
- Event-driven notifications

### 6. **Analytics Service** (Port 3006)
- Financial reports generation
- User activity analytics
- Transaction analytics
- Performance metrics

## Prerequisites

- **Local Development**: Docker, Docker Compose, Node.js 18+, npm/yarn
- **AWS Deployment**: AWS Account, AWS CLI configured, Terraform 1.x+
- **Kubernetes**: kubectl, Helm 3+

## Getting Started

### Local Development Setup

```bash
# Clone the repository
git clone <repo-url> eaglewings-bank-platform
cd eaglewings-bank-platform

# Start all services locally with Docker Compose
docker-compose up -d

# Access services
# - Frontend: http://localhost:3000
# - Auth Service: http://localhost:3001
# - Account Service: http://localhost:3002
# - Transaction Service: http://localhost:3003
# - Payment Service: http://localhost:3004
# - Notification Service: http://localhost:3005
# - Analytics Service: http://localhost:3006
# - PostgreSQL: localhost:5432
```

### Infrastructure Setup (AWS Deployment)

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan -var-file="environments/prod.tfvars"

# Apply the infrastructure
terraform apply -var-file="environments/prod.tfvars"

# Get the output (EKS cluster name, RDS endpoint, ECR registries)
terraform output
```

### Deploying to EKS

```bash
# Build and push Docker images to ECR
./scripts/build-and-push.sh

# Deploy using Helm or kubectl
helm install eaglewings-bank-platform ./kubernetes
```

## Environment Variables

### Common (All Services)
```
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=postgresql://user:password@host:5432/eaglewings_db
JWT_SECRET=your_secret_key_here
```

### Service-Specific
- Auth Service: `JWT_EXPIRY`, `REFRESH_TOKEN_EXPIRY`
- Notification Service: `SMTP_HOST`, `SMTP_PORT`, `TWILIO_ACCOUNT_SID`
- Payment Service: `STRIPE_API_KEY`, `PAYMENT_GATEWAY_URL`

## API Documentation

- **Auth Service**: http://localhost:3001/api-docs
- **Account Service**: http://localhost:3002/api-docs
- **Transaction Service**: http://localhost:3003/api-docs
- **Payment Service**: http://localhost:3004/api-docs
- **Notification Service**: http://localhost:3005/api-docs
- **Analytics Service**: http://localhost:3006/api-docs

## Database Schema

All services use a shared PostgreSQL database with the following main tables:
- `users` - User accounts and credentials
- `accounts` - Bank accounts
- `transactions` - Transaction records
- `payments` - Payment records
- `notifications` - Notification logs
- `analytics_events` - Analytics data

## Testing

```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration

# Run e2e tests
npm run test:e2e
```

## CI/CD Pipeline

This project uses:
- **GitHub Actions** for build and test
- **ArgoCD** for GitOps-based deployments to EKS
- **Automated image building and pushing to ECR**

## Security Considerations

- ✅ JWT-based authentication
- ✅ HTTPS/TLS everywhere
- ✅ Database encryption at rest and in transit
- ✅ Secrets managed via AWS Secrets Manager
- ✅ Network policies and RBAC in Kubernetes
- ✅ Regular dependency updates
- ✅ Vulnerability scanning in CI/CD

## Monitoring & Logging

- **CloudWatch** for logs and metrics
- **Application Insights** for APM
- **Prometheus & Grafana** for Kubernetes metrics
- **ELK Stack** for centralized logging (optional)

## Deployment Environments

- **Development**: Docker Compose locally
- **Staging**: EKS with staging configuration
- **Production**: EKS with high availability and auto-scaling

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. CI/CD pipeline will test and deploy

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.

---

**Built with ❤️ by EAGLEWINGS Team**
