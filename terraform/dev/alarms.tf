resource "aws_cloudwatch_metric_alarm" "api_request_alarm" {
  alarm_name          = "APIRequestThreshold-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Count"
  namespace           = "AWS/ApiGateway"
  period              = "900"
  statistic           = "Sum"
  threshold           = aws_ssm_parameter.api_gateway_request_threshold.value
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn, aws_lambda_function.protect_lambda.arn]
  dimensions = {
    ApiName = aws_api_gateway_rest_api.farm_api.name
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_request_alarm" {
  alarm_name          = "DynamoDBRequestThreshold-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "900"
  statistic           = "Sum"
  threshold           = aws_ssm_parameter.dynamodb_request_threshold.value
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]
  dimensions = {
    TableName = aws_dynamodb_table.farm.name
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_request_alarm" {
  alarm_name          = "S3RequestThreshold-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "AllRequests"
  namespace           = "AWS/S3"
  period              = "900"
  statistic           = "Sum"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]
  threshold           = aws_ssm_parameter.s3_request_threshold.value
  dimensions = {
    BucketName = aws_ssm_parameter.bucket_name_s3.value
  }
}

resource "aws_cloudwatch_metric_alarm" "step_function_failed_alarm" {
  alarm_name          = "StepFunctionSuccessRate-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ExecutionFailed"
  namespace           = "AWS/States"
  period              = "900"
  statistic           = "Sum"
  threshold           = tonumber(aws_ssm_parameter.step_function_failed_rate.value)
  alarm_actions       = [aws_sns_topic.alarm_notifications.arn]
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.farm_state_machine.arn
  }
}



resource "aws_ssm_parameter" "api_gateway_request_threshold" {
  name        = "api_gateway_request_threshold"
  type        = "String"
  value       = "300"
  description = "Próg liczby żądań dla API Gateway"
  overwrite   = true

}

resource "aws_ssm_parameter" "dynamodb_request_threshold" {
  name        = "dynamodb_request_threshold"
  type        = "String"
  value       = "300"
  description = "Próg liczby żądań dla DynamoDB"
  overwrite   = true

}

resource "aws_ssm_parameter" "s3_request_threshold" {
  name        = "s3_request_threshold"
  type        = "String"
  value       = "1500"
  description = "Próg liczby żądań dla S3"
  overwrite   = true

}
resource "aws_ssm_parameter" "step_function_failed_rate" {
  name        = "step_function_success_rate"
  type        = "String"
  value       = "0"
  description = "Liczba faili do alarmu"
  overwrite   = true

}

resource "aws_ssm_parameter" "bucket_name_s3" {
  name  = "step_function_success_rate"
  type  = "String"
  value = var.bucket_name
  lifecycle {
    create_before_destroy = true
  }
  overwrite = true

}
