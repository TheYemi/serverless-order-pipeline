variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "order-pipeline"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = "olasehindeo3@gmail.com"
}