resource "aws_lambda_function" "check_satisfaction_lambda" {
  function_name    = "check_satisfaction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "check_satisfaction.lambda_handler"
  source_code_hash = data.archive_file.check_satisfaction_code.output_base64sha256
  runtime          = "python3.12"
  filename         = data.archive_file.check_satisfaction_code.output_path
}

data "archive_file" "check_satisfaction_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/check_satisfaction"
  output_path = "${path.module}/../../lambdas/check_satisfaction.zip"
}
