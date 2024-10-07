resource "aws_lambda_function" "increase_animal_lambda" {
  function_name    = "increase_animal"
  role             = aws_iam_role.lambda_role.arn
  handler          = "increase_animal.lambda_handler"
  source_code_hash = data.archive_file.increase_animal_code.output_base64sha256
  runtime          = "python3.12"
  filename         = data.archive_file.increase_animal_code.output_path
}

data "archive_file" "increase_animal_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/increase_animal"
  output_path = "${path.module}/../../lambdas/increase_animal.zip"
}
