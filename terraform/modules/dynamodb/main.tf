resource "aws_dynamodb_table" "orders" {
  name         = "${var.environment}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"
  
  attribute {
    name = "order_id"
    type = "S"
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}