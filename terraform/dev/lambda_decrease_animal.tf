resource "aws_lambda_function" "decrease_animal_lambda" {
  function_name    = "decrease_animal"
  role             = aws_iam_role.lambda_role.arn
  handler          = "decrease_animal.lambda_handler"
  source_code_hash = data.archive_file.decrease_animal_code.output_base64sha256
  runtime          = "python3.12"
  filename         = data.archive_file.decrease_animal_code.output_path
}

data "archive_file" "decrease_animal_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/decrease_animal"
  output_path = "${path.module}/../../lambdas/decrease_animal.zip"
}
