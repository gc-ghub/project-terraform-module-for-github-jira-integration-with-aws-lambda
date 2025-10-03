
# 1. Create HTTP API
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.lambda_name}-api"
  protocol_type = "HTTP"
}

# 2. Lambda integration
resource "aws_apigatewayv2_integration" "lambda_integ" {
  api_id                 = aws_apigatewayv2_api.lambda_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda.arn
  payload_format_version = "2.0"
}

# 3. Route for the webhook
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /createJiraWebhook"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integ.id}"
}

# 4. Deploy stage
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "prod"
  auto_deploy = true
}

# 5. Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}



