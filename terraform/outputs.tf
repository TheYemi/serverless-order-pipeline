output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_url
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "accept_lambda_name" {
  description = "Accept order Lambda function name"
  value       = module.lambda.accept_lambda_name
}

output "process_lambda_name" {
  description = "Process order Lambda function name"
  value       = module.lambda.process_lambda_name
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = module.sqs.queue_url
}

output "dlq_url" {
  description = "Dead Letter Queue URL"
  value       = module.sqs.dlq_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = module.sns.topic_arn
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}