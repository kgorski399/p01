


resource "aws_lambda_function" "get_data_lambda" {
  function_name    = "get_data"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_data.lambda_handler"
  source_code_hash = data.archive_file.get_data_code.output_base64sha256
  runtime          = "python3.12"
  filename         = data.archive_file.get_data_code.output_path
}

# Archive ZIP for the "get_data" Lambda function
data "archive_file" "get_data_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/get_data"
  output_path = "${path.module}/../../lambdas/get_data.zip"
}
