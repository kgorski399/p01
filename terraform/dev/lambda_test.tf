# Provider AWS
provider "aws" {
  region = "us-east-1" 
}



variable "zip_hash" {
  type = string
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/../../lambdas/testlambda/lambda_function.zip"

  # use hash from output GA variable
  source_code_hash = "${var.zip_hash}"
}
