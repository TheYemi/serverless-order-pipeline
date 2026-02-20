output "api_url" {
  description = "API Gateway URL"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}/orders"
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = aws_apigatewayv2_api.main.api_endpoint
}