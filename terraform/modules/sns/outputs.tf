output "topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.order_notifications.arn
}

output "topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.order_notifications.name
}