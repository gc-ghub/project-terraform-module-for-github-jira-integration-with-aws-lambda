# Lambda from container image
resource "aws_lambda_function" "lambda" {
  package_type  = "Image"
  function_name = var.lambda_name
  image_uri     = "${aws_ecr_repository.this.repository_url}:${var.repo_image_tag}"
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 15
  memory_size   = 512

  environment {
    variables = {
      JIRA_SECRET_ARN = var.create_secret ? aws_secretsmanager_secret.jira[0].arn : ""
      # Optionally other env vars: e.g. LOG_LEVEL = "INFO"
    }
  }

  depends_on = [null_resource.docker_build_push]
}