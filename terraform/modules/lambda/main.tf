# ============================================
# ACCEPT ORDER LAMBDA
# ============================================
resource "aws_iam_role" "accept_lambda_role" {
  name = "${var.environment}-accept-order-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "accept_lambda_logs" {
  role       = aws_iam_role.accept_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "accept_lambda_policy" {
  name = "${var.environment}-accept-lambda-policy"
  role = aws_iam_role.accept_lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:PutItem"]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow"
        Action = ["sqs:SendMessage"]
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

# Lambda Function
data "archive_file" "accept_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/lambda/accept-order"
  output_path = "${path.module}/accept_lambda.zip"
}

resource "aws_lambda_function" "accept_order" {
  filename         = data.archive_file.accept_lambda_zip.output_path
  function_name    = "${var.environment}-accept-order"
  role             = aws_iam_role.accept_lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.accept_lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10
  
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SQS_QUEUE_URL  = var.sqs_queue_url
      ENVIRONMENT    = var.environment
    }
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "accept_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.accept_order.function_name}"
  retention_in_days = 7
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ============================================
# PROCESS ORDER LAMBDA
# ============================================
resource "aws_iam_role" "process_lambda_role" {
  name = "${var.environment}-process-order-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "process_lambda_logs" {
  role       = aws_iam_role.process_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "process_lambda_policy" {
  name = "${var.environment}-process-lambda-policy"
  role = aws_iam_role.process_lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
        Resource = var.dynamodb_table_arn
      },
      {
        Effect = "Allow"
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes" ]
        Resource = var.sqs_queue_arn
      },
      {
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = var.sns_topic_arn
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject"]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

# Lambda Function
data "archive_file" "process_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/lambda/process-order"
  output_path = "${path.module}/process_lambda.zip"
}

resource "aws_lambda_function" "process_order" {
  filename         = data.archive_file.process_lambda_zip.output_path
  function_name    = "${var.environment}-process-order"
  role             = aws_iam_role.process_lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.process_lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30
  
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
      S3_BUCKET      = var.s3_bucket_name
      ENVIRONMENT    = var.environment
    }
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "process_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.process_order.function_name}"
  retention_in_days = 7
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.process_order.arn
  batch_size       = 10
  enabled          = true
}

# ============================================
# GET ORDERS LAMBDA
# ============================================
resource "aws_iam_role" "get_orders_lambda_role" {
  name = "${var.environment}-get-orders-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "get_orders_lambda_logs" {
  role       = aws_iam_role.get_orders_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "get_orders_lambda_policy" {
  name = "${var.environment}-get-orders-lambda-policy"
  role = aws_iam_role.get_orders_lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:Scan"]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

data "archive_file" "get_orders_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/lambda/get-orders"
  output_path = "${path.module}/get_orders_lambda.zip"
}

resource "aws_lambda_function" "get_orders" {
  filename         = data.archive_file.get_orders_lambda_zip.output_path
  function_name    = "${var.environment}-get-orders"
  role             = aws_iam_role.get_orders_lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.get_orders_lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10
  
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      ENVIRONMENT    = var.environment
    }
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "get_orders_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.get_orders.function_name}"
  retention_in_days = 7
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}