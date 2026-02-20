variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "dlq_name" {
  description = "Dead letter queue name"
  type        = string
}

variable "process_lambda_name" {
  description = "Process Lambda function name"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  type        = string
}