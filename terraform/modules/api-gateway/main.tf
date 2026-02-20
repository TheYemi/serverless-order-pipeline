resource "aws_apigatewayv2_api" "main" {
  name          = "${var.environment}-${var.project_name}-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["Content-Type"]
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_apigatewayv2_integration" "accept_order" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.accept_lambda_invoke_arn
  
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_order" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /orders"
  target    = "integrations/${aws_apigatewayv2_integration.accept_order.id}"
}

resource "aws_lambda_permission" "api_gateway_accept" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.accept_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "get_orders" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.get_orders_lambda_invoke_arn
  
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_orders_list" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /orders"
  target    = "integrations/${aws_apigatewayv2_integration.get_orders.id}"
}

resource "aws_apigatewayv2_route" "get_order_by_id" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /orders/{order_id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_orders.id}"
}

resource "aws_lambda_permission" "api_gateway_get_orders" {
  statement_id  = "AllowAPIGatewayInvokeGetOrders"
  action        = "lambda:InvokeFunction"
  function_name = var.get_orders_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}