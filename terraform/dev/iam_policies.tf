resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "LambdaDynamoDBPolicy"
  description = "Allow Lambda to access and modify DynamoDB table and read from Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "${aws_dynamodb_table.farm.arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/farm_id"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_protect_resources_policy" {
  name = "lambda_exec_protect_resources_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "apigateway:DELETE"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/api_id"
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_read_policy" {
  name = "SSMReadPolicy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ssm:GetParameter",
        "Resource" : "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/sms_number"
      }
    ]
  })
}
