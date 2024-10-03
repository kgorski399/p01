resource "aws_api_gateway_rest_api" "farm_api" {
  name        = "Farm API"
  description = "API for managing farm data."
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_resource" "get_data_resource" {
  rest_api_id = aws_api_gateway_rest_api.farm_api.id
  parent_id   = aws_api_gateway_rest_api.farm_api.root_resource_id
  path_part   = "get-data"
}

resource "aws_api_gateway_resource" "feed_or_water_resource" {
  rest_api_id = aws_api_gateway_rest_api.farm_api.id
  parent_id   = aws_api_gateway_rest_api.farm_api.root_resource_id
  path_part   = "feed-or-water"
}


resource "aws_api_gateway_method" "get_data_method" {
  rest_api_id   = aws_api_gateway_rest_api.farm_api.id
  resource_id   = aws_api_gateway_resource.get_data_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "feed_or_water_method" {
  rest_api_id   = aws_api_gateway_rest_api.farm_api.id
  resource_id   = aws_api_gateway_resource.feed_or_water_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_data_integration" {
  rest_api_id             = aws_api_gateway_rest_api.farm_api.id
  resource_id             = aws_api_gateway_resource.get_data_resource.id
  http_method             = aws_api_gateway_method.get_data_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_data_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "feed_or_water_integration" {
  rest_api_id             = aws_api_gateway_rest_api.farm_api.id
  resource_id             = aws_api_gateway_resource.feed_or_water_resource.id
  http_method             = aws_api_gateway_method.feed_or_water_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.feed_or_water_function.invoke_arn
}


resource "aws_lambda_permission" "get_data_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_data_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.farm_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "feed_or_water_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.feed_or_water_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.farm_api.execution_arn}/*/*"
}


resource "aws_api_gateway_deployment" "farm_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.farm_api.id
  stage_name  = "develop"

  depends_on = [
    aws_api_gateway_integration.get_data_integration,
    aws_api_gateway_integration.feed_or_water_integration
  ]
}
