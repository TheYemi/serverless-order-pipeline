# Serverless Order Processing Pipeline

![Deploy Status](https://github.com/TheYemi/serverless-order-pipeline/actions/workflows/deploy.yml/badge.svg)

A production-grade serverless architecture for processing orders asynchronously on AWS. Built with Terraform modules, automated CI/CD, and comprehensive monitoring.

## Architecture
```
┌─────────┐
│  User   │
└────┬────┘
     │ POST /orders
     ↓
┌──────────────────┐
│  API Gateway     │
│  (HTTP API)      │
└────┬─────────────┘
     │
     ↓
┌──────────────────────┐
│ Accept Order Lambda  │  (Fast - 50ms)
│ - Validate order     │
│ - Save to DynamoDB   │
│ - Queue for process  │
└──┬───────────────┬───┘
   │               │
   ↓               ↓
┌─────────┐   ┌─────────┐
│DynamoDB │   │   SQS   │
│(PENDING)│   │  Queue  │
└─────────┘   └────┬────┘
                   │
                   ↓
         ┌──────────────────────┐
         │ Process Order Lambda │  (Slow - 2.5s)
         │ - Check inventory    │
         │ - Fraud detection    │
         │ - Process payment    │
         └──┬───────────────┬───┘
            │               │
            ↓               ↓
       ┌─────────┐     ┌─────┐
       │DynamoDB │     │ SNS │
       │(COMPLETE)│     │Email│
       └─────────┘     └─────┘
                           │
                           ↓
                    ┌──────────┐
                    │   User   │
                    │  Email   │
                    └──────────┘

Dead Letter Queue (DLQ)
       ↑
       │ (after 3 failed retries)
       │
   ┌───┴────┐
   │CloudWatch│
   │ Alarms  │
   └─────────┘
```

## Features

### Asynchronous Processing
- **Accept Lambda** returns `202 Accepted` immediately (~50ms)
- **Process Lambda** handles heavy operations in background (~2.5s)
- User doesn't wait for order processing to complete

### Fault Tolerance
- **SQS Queue** with automatic retries (up to 3 attempts)
- **Dead Letter Queue** captures failed messages
- **CloudWatch Alarms** alert on failures

### Scalability
- **Pay-per-request** DynamoDB (auto-scales)
- **Lambda** scales to 1000 concurrent executions
- **SQS** handles unlimited messages

### Observability
- **Structured logging** in CloudWatch
- **Alarms** for Lambda errors and DLQ messages
- **Metrics** tracked for all services

## Tech Stack

| Component | Technology |
|-----------|------------|
| **API** | API Gateway (HTTP API) |
| **Compute** | AWS Lambda (Python 3.11) |
| **Database** | DynamoDB (NoSQL) |
| **Messaging** | SQS + Dead Letter Queue |
| **Notifications** | SNS (Email) |
| **Storage** | S3 (Receipts) |
| **Monitoring** | CloudWatch (Logs, Metrics, Alarms) |
| **IaC** | Terraform (Modular) |
| **CI/CD** | GitHub Actions |
| **State Management** | S3 Backend + DynamoDB Lock |

## Project Structure
```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          
├── src/
│   └── lambda/
│       ├── accept-order/       
│       ├── process-order/      
│       └── get-orders/         
├── terraform/
│   ├── main.tf                 
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── api-gateway/        
│       ├── dynamodb/           
│       ├── lambda/             
│       ├── monitoring/         
│       ├── s3/                 
│       ├── sns/                
│       └── sqs/                
├── tests/
│   ├── unit/                   # lambda unit tests
│   ├── integration/            # api integration tests
│   └── infrastructure/         # terraform validation
└── README.md
```

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- Python 3.11
- Git

## Setup & Deployment

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/serverless-order-pipeline.git
cd serverless-order-pipeline
```

### 2. Configure Backend (First Time Only)

Create S3 bucket and DynamoDB table for remote state:
```bash
# Create S3 bucket
aws s3 mb s3://YOUR-UNIQUE-BUCKET-NAME --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket YOUR-UNIQUE-BUCKET-NAME \
  --versioning-configuration Status=Enabled

# Create DynamoDB lock table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Update `terraform/main.tf` backend block with your bucket name.

### 3. Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 4. Confirm Email Subscription

After deployment:
1. Check your email for SNS subscription confirmation
2. Click the confirmation link
3. Test the pipeline

## API Endpoints

Base URL: `https://{api-id}.execute-api.us-east-1.amazonaws.com/dev`

### Create Order
```bash
POST /orders
Content-Type: application/json

{
  "order_id": "ORD_001",
  "customer_id": "CUST_123",
  "total": 99.99
}

Response: 202 Accepted
{
  "message": "Order accepted for processing",
  "order_id": "ORD_001"
}
```

### Get Single Order
```bash
GET /orders/{order_id}

Response: 200 OK
{
  "order_id": "ORD_001",
  "customer_id": "CUST_123",
  "total": "99.99",
  "status": "COMPLETED",
  "timestamp": "2026-02-20T18:50:09.272530"
}
```

### List All Orders
```bash
GET /orders

Response: 200 OK
{
  "orders": [...],
  "count": 5
}
```

### List Orders by Status
```bash
GET /orders?status=COMPLETED
GET /orders?status=PENDING
GET /orders?status=FAILED
```

## Testing Locally
```bash
# Install dependencies
pip install pytest boto3 moto requests

# Run unit tests
pytest tests/unit -v

# Run infrastructure tests
pytest tests/infrastructure -v
```

## CI/CD Pipeline

Automated deployment via GitHub Actions:

**On Pull Request:**
-  Run unit tests
- Run infrastructure tests
- Show Terraform plan

**On Push to Main:**
-  Run all tests
- Deploy to AWS
- Run integration tests

## Monitoring

### CloudWatch Alarms

- **DLQ Messages** - Alerts when messages fail 3+ times
- **Lambda Errors** - Alerts when >5 errors in 5 minutes

### Logs
```bash
# Accept Lambda logs
aws logs tail /aws/lambda/dev-accept-order --follow

# Process Lambda logs
aws logs tail /aws/lambda/dev-process-order --follow

# Get Lambda logs
aws logs tail /aws/lambda/dev-get-orders --follow
```

### Metrics

View in CloudWatch console:
- API Gateway request count
- Lambda invocations, errors, duration
- SQS queue depth
- DynamoDB read/write capacity

## Architecture Decisions

### Why Async Processing?

- **Better UX**: User gets instant response (202), doesn't wait
- **Scalability**: Can handle traffic spikes without timeouts
- **Reliability**: Failed orders retry automatically
- **Decoupling**: Accept and Process are independent

### Why SQS over Direct Lambda?

- **Retry Logic**: Automatic retries with exponential backoff
- **DLQ**: Failed messages captured for investigation
- **Visibility**: Can see queue depth in CloudWatch

### Why Modular Terraform?

- **Readability**: Easy to find specific resources
- **Reusability**: Can use modules in other projects
- **Maintainability**: Update one module without touching others
- **Testing**: Can test modules independently

## Cleanup

To destroy all infrastructure:
```bash
cd terraform
terraform destroy
```

**Note:** This will delete:
- All Lambda functions
- DynamoDB table (and all orders)
- SQS queues
- API Gateway
- S3 bucket (must be empty first)

## Future Enhancements

- [ ] Add authentication (API keys or Cognito)
- [ ] Implement GET /orders pagination
- [ ] Add UPDATE /orders endpoint
- [ ] Add DELETE /orders endpoint

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

- Built as part of DevOps portfolio
- Designed for demonstrating serverless architecture patterns
- Infrastructure as Code best practices