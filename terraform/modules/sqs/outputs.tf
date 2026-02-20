output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.order_processing.url
}

output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.order_processing.arn
}

output "dlq_url" {
  description = "Dead letter queue URL"
  value       = aws_sqs_queue.order_processing_dlq.url
}

output "dlq_arn" {
  description = "Dead letter queue ARN"
  value       = aws_sqs_queue.order_processing_dlq.arn
}

output "dlq_name" {
  description = "Dead letter queue name"
  value       = aws_sqs_queue.order_processing_dlq.name
}