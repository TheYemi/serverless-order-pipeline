terraform {
  required_version = ">= 1.0"

    backend "s3" {
    bucket         = "yemi-terraform-state-serverless-pipeline"
    key            = "serverless-order-pipeline/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# DynamoDB module
module "dynamodb" {
  source      = "./modules/dynamodb"
  environment = var.environment
  project_name = var.project_name
}

# SNS module
module "sns" {
  source             = "./modules/sns"
  environment        = var.environment
  project_name       = var.project_name
  notification_email = var.notification_email
}

# S3 module
module "s3" {
  source       = "./modules/s3"
  environment  = var.environment
  project_name = var.project_name
  account_id   = data.aws_caller_identity.current.account_id
}

# SQS module
module "sqs" {
  source        = "./modules/sqs"
  environment   = var.environment
  project_name  = var.project_name
  sns_topic_arn = module.sns.topic_arn
}

# Lambda module
module "lambda" {
  source              = "./modules/lambda"
  environment         = var.environment
  project_name        = var.project_name
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  sqs_queue_url       = module.sqs.queue_url
  sqs_queue_arn       = module.sqs.queue_arn
  sns_topic_arn       = module.sns.topic_arn
  s3_bucket_name      = module.s3.bucket_name
  s3_bucket_arn       = module.s3.bucket_arn
}

# API Gateway module
module "api_gateway" {
  source                  = "./modules/api-gateway"
  environment             = var.environment
  project_name            = var.project_name
  accept_lambda_arn       = module.lambda.accept_lambda_arn
  accept_lambda_name      = module.lambda.accept_lambda_name
  accept_lambda_invoke_arn = module.lambda.accept_lambda_invoke_arn
  get_orders_lambda_arn       = module.lambda.get_orders_lambda_arn
  get_orders_lambda_name      = module.lambda.get_orders_lambda_name
  get_orders_lambda_invoke_arn = module.lambda.get_orders_lambda_invoke_arn
}

# Monitoring module
module "monitoring" {
  source                    = "./modules/monitoring"
  environment               = var.environment
  project_name              = var.project_name
  dlq_name                  = module.sqs.dlq_name
  process_lambda_name       = module.lambda.process_lambda_name
  sns_topic_arn             = module.sns.topic_arn
}