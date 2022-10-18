resource "aws_apigatewayv2_api" "lambda" {
  name          = "news_api_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "news_api_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw_hacker_news/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 1
}

# Get news
resource "aws_apigatewayv2_integration" "api_gw_integration" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.news_api_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gw_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /news_api"
  target    = "integrations/${aws_apigatewayv2_integration.api_gw_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_api_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

# Fav news
resource "aws_apigatewayv2_integration" "api_gw_fav_integration" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.news_api_fav_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gw_fav_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /fav_news"
  target    = "integrations/${aws_apigatewayv2_integration.api_gw_fav_integration.id}"
}

resource "aws_lambda_permission" "api_fav_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_api_fav_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

# Get favs
resource "aws_apigatewayv2_integration" "api_gw_get_favs_integration" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.news_api_get_favs_function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gw_get_favs_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /fav_news"
  target    = "integrations/${aws_apigatewayv2_integration.api_gw_get_favs_integration.id}"
}

resource "aws_lambda_permission" "api_get_favs_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_api_get_favs_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}