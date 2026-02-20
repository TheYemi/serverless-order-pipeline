variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  type        = string
}