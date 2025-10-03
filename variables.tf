variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "lambda_name" {
  description = "Lambda function name"
  default     = "github-to-jira-lambda"
}

variable "create_secret" {
  description = "Whether to create a Secrets Manager secret (true/false)"
  type        = bool
  default     = true
}

variable "jira_secret_string" {
  description = "JSON string for Jira secrets when create_secret=true. Example: {\"JIRA_ISSUES_URL\":\"https://...\",\"JIRA_EMAIL\":\"e@x.com\",\"JIRA_API_TOKEN\":\"token\"}"
  type        = string
  default     = ""
}

variable "repo_image_tag" {
  description = "Image tag to push"
  default     = "latest"
}
