resource "aws_cloudwatch_metric_alarm" "api_request_alarm" {
  alarm_name          = "APIRequestThreshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Count"
  namespace           = "AWS/ApiGateway"
  period              = "3600"
  statistic           = "Sum"
  threshold           = "600"
  alarm_actions       = [aws_lambda_function.protect_lambda.arn]
  dimensions = {
    ApiName = aws_api_gateway_rest_api.farm_api.name
  }
}
