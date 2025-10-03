
output "lambda_name" {
  value = aws_lambda_function.lambda.function_name
}

output "github_webhook_url" {
  value = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/createJiraWebhook"
}