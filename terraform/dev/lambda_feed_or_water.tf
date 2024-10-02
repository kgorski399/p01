


resource "aws_lambda_function" "feed_or_water_function" {
  function_name    = "feed_or_water_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "feed_or_water.lambda_handler"
  source_code_hash = data.archive_file.feed_or_water_code.output_base64sha256
  runtime          = "python3.12"
  filename         = data.archive_file.feed_or_water_code.output_path
}

# Archive ZIP for the "feed_or_water" Lambda function
data "archive_file" "feed_or_water_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/feed_or_water"
  output_path = "${path.module}/../../lambdas/feed_or_water.zip"
}
