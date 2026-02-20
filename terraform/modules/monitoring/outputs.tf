output "dlq_alarm_name" {
  description = "DLQ CloudWatch alarm name"
  value       = aws_cloudwatch_metric_alarm.dlq_messages.alarm_name
}

output "lambda_errors_alarm_name" {
  description = "Lambda errors CloudWatch alarm name"
  value       = aws_cloudwatch_metric_alarm.process_lambda_errors.alarm_name
}