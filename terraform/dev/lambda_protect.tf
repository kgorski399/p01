data "archive_file" "protect_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/protect"
  output_path = "${path.module}/../../lambdas/protect.zip"
}

resource "aws_lambda_function" "protect_lambda" {
  function_name    = "protect"
  role             = aws_iam_role.lambda_protect_exec_role.arn
  handler          = "protect.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.protect_code.output_path
  source_code_hash = data.archive_file.protect_code.output_base64sha256
}
