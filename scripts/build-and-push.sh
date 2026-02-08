#!/bin/bash

# EAGLEWINGS Bank Platform - Build and Push Script

set -e

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPOSITORY="eaglewings-bank"

echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "ECR Registry: $ECR_REGISTRY"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and push Auth Service
echo "Building and pushing Auth Service..."
cd backend/services/auth-service
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/auth-service:latest .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/auth-service:latest
cd ../../..

# Build and push Account Service
echo "Building and pushing Account Service..."
cd backend/services/account-service
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/account-service:latest .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/account-service:latest
cd ../../..

# Build and push Transaction Service
echo "Building and pushing Transaction Service..."
cd backend/services/transaction-service
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/transaction-service:latest .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/transaction-service:latest
cd ../../..

# Build and push Payment Service
echo "Building and pushing Payment Service..."
cd backend/services/payment-service
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/payment-service:latest .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/payment-service:latest
cd ../../..

# Build and push Notification Service
echo "Building and pushing Notification Service..."
cd backend/services/notification-service
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/notification-service:latest .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/notification-service:latest
cd ../../..

# Build and push Analytics Service
echo "Building and pushing Analytics Service..."
cd backend/services/analytics-service
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/analytics-service:latest .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/analytics-service:latest
cd ../../..

# Build and push Frontend
echo "Building and pushing Frontend..."
cd frontend
docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/frontend:latest -f ../docker/Dockerfile.frontend .
docker push $ECR_REGISTRY/$ECR_REPOSITORY/frontend:latest
cd ..

echo "✅ All images built and pushed successfully!"
echo "ECR Repository: $ECR_REGISTRY/$ECR_REPOSITORY"
