data "archive_file" "update_satisfaction_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/update_satisfaction"
  output_path = "${path.module}/../../lambdas/update_satisfaction.zip"
}

resource "aws_lambda_function" "update_satisfaction_lambda" {
  function_name    = "update_satisfaction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "update_satisfaction.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.update_satisfaction_code.output_path
  source_code_hash = data.archive_file.update_satisfaction_code.output_base64sha256
}
