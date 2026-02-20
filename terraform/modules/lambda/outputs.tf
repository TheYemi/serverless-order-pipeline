output "accept_lambda_arn" {
  description = "Accept Lambda function ARN"
  value       = aws_lambda_function.accept_order.arn
}

output "accept_lambda_name" {
  description = "Accept Lambda function name"
  value       = aws_lambda_function.accept_order.function_name
}

output "accept_lambda_invoke_arn" {
  description = "Accept Lambda invoke ARN"
  value       = aws_lambda_function.accept_order.invoke_arn
}

output "process_lambda_arn" {
  description = "Process Lambda function ARN"
  value       = aws_lambda_function.process_order.arn
}

output "process_lambda_name" {
  description = "Process Lambda function name"
  value       = aws_lambda_function.process_order.function_name
}

output "get_orders_lambda_arn" {
  description = "Get orders Lambda function ARN"
  value       = aws_lambda_function.get_orders.arn
}

output "get_orders_lambda_name" {
  description = "Get orders Lambda function name"
  value       = aws_lambda_function.get_orders.function_name
}

output "get_orders_lambda_invoke_arn" {
  description = "Get orders Lambda invoke ARN"
  value       = aws_lambda_function.get_orders.invoke_arn
}