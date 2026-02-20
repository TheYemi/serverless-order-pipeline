resource "aws_sns_topic" "order_notifications" {
  name = "${var.environment}-order-notifications"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}