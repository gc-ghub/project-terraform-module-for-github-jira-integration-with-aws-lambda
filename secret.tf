
# Generate a random string
resource "random_string" "secret_suffix" {
  length  = 6
  upper   = false
  special = false
}

# Secret Manager with random suffix
resource "aws_secretsmanager_secret" "jira" {
  count = var.create_secret ? 1 : 0
  name  = "${var.lambda_name}-jira-credentials-${random_string.secret_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "jira_version" {
  count     = var.create_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.jira[0].id
  secret_string = var.jira_secret_string != "" ? var.jira_secret_string : jsonencode({
    JIRA_ISSUES_URL = "https://your-jira-url/rest/api/2/issue"
    JIRA_EMAIL      = "you@example.com"
    JIRA_API_TOKEN  = "changeme"
  })
}
