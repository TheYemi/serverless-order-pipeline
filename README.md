# Serverless Order Processing Pipeline

AWS serverless architecture for processing orders asynchronously using Lambda, SQS, DynamoDB, and SNS.

## Architecture

- **HTTP API** - RESTful endpoints via API Gateway
- **Lambda Functions** - Accept, Process, and Retrieve orders
- **SQS** - Async message queue with Dead Letter Queue
- **DynamoDB** - Order storage
- **SNS** - Email notifications
- **S3** - Receipt storage
- **CloudWatch** - Monitoring and alarms

## Setup
```bash
cd terraform
terraform init
terraform apply
```

## API Endpoints

- `POST /orders` - Create new order
- `GET /orders` - List all orders
- `GET /orders/{id}` - Get order by ID