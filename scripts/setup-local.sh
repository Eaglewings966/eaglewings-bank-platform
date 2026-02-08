#!/bin/bash

# EAGLEWINGS Bank Platform - Local Setup Script

set -e

echo "🚀 EAGLEWINGS Bank Platform - Local Setup"

# Check dependencies
echo "📋 Checking dependencies..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    exit 1
fi

echo "✅ All dependencies found"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
cd backend/shared && npm install && cd ../..
cd backend && npm install && cd ..
cd frontend && npm install && cd ..

echo "✅ Dependencies installed"

# Start Docker Compose
echo ""
echo "🐳 Starting Docker Compose services..."
docker-compose up -d

sleep 10

# Check if services are running
echo ""
echo "🔍 Checking service health..."

services=(
  "http://localhost:3001/health"
  "http://localhost:3002/health"
  "http://localhost:3003/health"
  "http://localhost:3004/health"
  "http://localhost:3005/health"
  "http://localhost:3006/health"
)

for service in "${services[@]}"; do
  if curl -s "$service" > /dev/null; then
    echo "✅ $service is healthy"
  else
    echo "⚠️  $service is not responding yet"
  fi
done

echo ""
echo "✅ EAGLEWINGS Bank Platform is ready!"
echo ""
echo "📝 Services:"
echo "  Frontend:             http://localhost:3000"
echo "  Auth Service:         http://localhost:3001"
echo "  Account Service:      http://localhost:3002"
echo "  Transaction Service:  http://localhost:3003"
echo "  Payment Service:      http://localhost:3004"
echo "  Notification Service: http://localhost:3005"
echo "  Analytics Service:    http://localhost:3006"
echo "  PostgreSQL:           postgresql://postgres:postgres123@localhost:5432/eaglewings_db"
echo ""
echo "📋 Useful commands:"
echo "  docker-compose logs -f                      # View all logs"
echo "  docker-compose logs -f <service-name>       # View specific service logs"
echo "  docker-compose down                         # Stop all services"
echo "  docker-compose restart                      # Restart services"
