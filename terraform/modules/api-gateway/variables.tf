variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "accept_lambda_arn" {
  description = "Accept Lambda function ARN"
  type        = string
}

variable "accept_lambda_name" {
  description = "Accept Lambda function name"
  type        = string
}

variable "accept_lambda_invoke_arn" {
  description = "Accept Lambda invoke ARN"
  type        = string
}

variable "get_orders_lambda_arn" {
  description = "Get orders Lambda function ARN"
  type        = string
}

variable "get_orders_lambda_name" {
  description = "Get orders Lambda function name"
  type        = string
}

variable "get_orders_lambda_invoke_arn" {
  description = "Get orders Lambda invoke ARN"
  type        = string
}