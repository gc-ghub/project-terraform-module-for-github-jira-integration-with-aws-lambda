# ECR repo for lambda image
resource "aws_ecr_repository" "this" {
  name                 = "${var.lambda_name}-repo"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}