# Provider AWS
provider "aws" {
  region = "us-east-1" 
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

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
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "zip_hash" {
  type = string
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"

  role          = aws_iam_role.lambda_role.arn
  filename      = "../lambdas/testlambda/lambda_function.zip"

  # use hash from output GA variable
  source_code_hash = "${var.zip_hash}"
}
