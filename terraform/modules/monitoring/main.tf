# Alert when messages go to DLQ
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.environment}-order-dlq-has-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when messages appear in DLQ"
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    QueueName = var.dlq_name
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Alert on Lambda errors
resource "aws_cloudwatch_metric_alarm" "process_lambda_errors" {
  alarm_name          = "${var.environment}-process-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when process Lambda has errors"
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    FunctionName = var.process_lambda_name
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}