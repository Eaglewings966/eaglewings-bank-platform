# Architecture and API Design

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend (React)                      │
│            Deployed on CloudFront + S3 / ECS                 │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS/TLS
┌────────────────────────▼────────────────────────────────────┐
│            API Gateway / Application Load Balancer           │
│                    (with WAF rules)                          │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│               Kubernetes (EKS) Cluster                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            Microservices (Node.js)                    │   │
│  │  Auth   │ Account │ Transaction │ Payment │ ...      │   │
│  │  Service│ Service │  Service    │Service  │          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Ingress + NGINX Controller                    │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│    Amazon RDS PostgreSQL (Multi-AZ) Database                │
│         • Encrypted at rest and in transit                  │
│         • Automated backups and failover                    │
│         • Enhanced monitoring                               │
└─────────────────────────────────────────────────────────────┘
```

## Microservices Description

### Auth Service
- **Port**: 3001
- **Responsibilities**: User authentication, JWT token management, password management
- **Database**: Shared (users table)
- **Key Endpoints**:
  - `POST /api/auth/register` - Register new user
  - `POST /api/auth/login` - Authenticate user
  - `POST /api/auth/refresh-token` - Refresh expired token
  - `GET /api/auth/profile` - Get user profile
  - `PUT /api/auth/change-password` - Change password

### Account Service
- **Port**: 3002
- **Responsibilities**: Bank account management, balance tracking
- **Database**: Shared (accounts table)
- **Key Endpoints**:
  - `POST /api/accounts` - Create new account
  - `GET /api/accounts` - List user accounts
  - `GET /api/accounts/:id` - Get account details
  - `PUT /api/accounts/:id` - Update account
  - `DELETE /api/accounts/:id` - Close account
  - `GET /api/accounts/:id/balance` - Get account balance

### Transaction Service
- **Port**: 3003
- **Responsibilities**: Financial transaction processing and history
- **Database**: Shared (transactions table)
- **Key Endpoints**:
  - `POST /api/transactions/transfer` - Transfer between accounts
  - `POST /api/transactions/deposit` - Deposit money
  - `POST /api/transactions/withdraw` - Withdraw money
  - `GET /api/transactions/history` - Get transaction history
  - `GET /api/transactions/:id` - Get transaction details

### Payment Service
- **Port**: 3004
- **Responsibilities**: Payment processing and gateway integration
- **Database**: Shared (payments table)
- **Key Endpoints**:
  - `POST /api/payments/initiate` - Initiate payment
  - `POST /api/payments/confirm` - Confirm payment with OTP
  - `GET /api/payments/status/:id` - Get payment status
  - `GET /api/payments/history` - Get payment history

### Notification Service
- **Port**: 3005
- **Responsibilities**: Email, SMS, and push notifications
- **Database**: Shared (notifications, notification_preferences tables)
- **Key Endpoints**:
  - `POST /api/notifications/send-email` - Send email
  - `POST /api/notifications/send-sms` - Send SMS
  - `GET /api/notifications/history/:userId` - Get notification history
  - `PUT /api/notifications/preferences/:userId` - Update user preferences

### Analytics Service
- **Port**: 3006
- **Responsibilities**: Financial analytics and reporting
- **Database**: Shared (read-only access to all tables)
- **Key Endpoints**:
  - `GET /api/analytics/user-activity` - Get user activity
  - `GET /api/analytics/transaction-summary` - Get transaction summary
  - `GET /api/analytics/account-analytics` - Get account analytics
  - `GET /api/analytics/reports` - Generate reports

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Accounts Table
```sql
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  account_type VARCHAR(50) NOT NULL,
  balance DECIMAL(15, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Transactions Table
```sql
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  from_account_id INTEGER REFERENCES accounts(id),
  to_account_id INTEGER REFERENCES accounts(id),
  amount DECIMAL(15, 2) NOT NULL,
  transaction_type VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'PENDING',
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## API Standards

All APIs follow REST conventions with the following standards:

### Request Format
```json
{
  "field1": "value1",
  "field2": "value2"
}
```

### Success Response
```json
{
  "status": "success",
  "data": { /* response data */ },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "status": "error",
  "error": "Error description",
  "code": "ERROR_CODE"
}
```

### Status Codes
- 200: OK
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Authentication

All endpoints (except /register and /login) require JWT token in Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Rate Limiting

API rate limits apply per user:
- Authentication endpoints: 5 requests per minute
- Other endpoints: 100 requests per minute
- Analytics endpoints: 20 requests per minute

## Versioning

APIs use URL versioning: `/api/v1/...`

Current version: v1

## Error Codes

- `ERR_INVALID_CREDENTIALS`: Invalid email/password
- `ERR_UNAUTHORIZED`: Missing or invalid token
- `ERR_INVALID_ACCOUNT`: Account not found or invalid
- `ERR_INSUFFICIENT_BALANCE`: Not enough balance for transaction
- `ERR_DATABASE_ERROR`: Database operation failed
- `ERR_INVALID_REQUEST`: Invalid request parameters
