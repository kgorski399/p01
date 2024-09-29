# Provider AWS
provider "aws" {
  region = "us-east-1" 
}


data "archive_file" "testlambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/testlambda"
  output_path = "${path.module}/../../lambdas/testlambda.zip"
}

resource "aws_lambda_function" "my_lambda" {
  function_name    = "my_lambda_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.testlambda_code.output_base64sha256
  runtime          = "python3.12"
  filename         = data.archive_file.testlambda_code.output_path
}