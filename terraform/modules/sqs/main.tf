resource "aws_sqs_queue" "order_processing_dlq" {
  name                      = "${var.environment}-order-processing-dlq"
  message_retention_seconds = 1209600
  
  tags = {
    Name        = "${var.environment}-order-processing-dlq"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sqs_queue" "order_processing" {
  name                       = "${var.environment}-order-processing"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_processing_dlq.arn
    maxReceiveCount     = 3
  })
  
  tags = {
    Name        = "${var.environment}-order-processing-queue"
    Environment = var.environment
    Project     = var.project_name
  }
}