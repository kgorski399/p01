

variable "zip_hash_feed_or_water" {
  type = string
}

resource "aws_lambda_function" "feed_or_water_function" {
  function_name = "feed_or_water_function"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/../../lambdas/feed_or_water/feed_or_water.zip"

  # use hash from output GA variable
  source_code_hash = "${var.zip_hash_feed_or_water}"
}
