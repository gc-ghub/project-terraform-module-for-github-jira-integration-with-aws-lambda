
# Build & push Docker image (local machine must have Docker & aws cli configured)
resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<EOT
REPO_URI="${aws_ecr_repository.this.repository_url}" && \
IMAGE_TAG="${var.repo_image_tag}" && \
echo "Logging in to ECR..." && \
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin $REPO_URI && \
echo "Building Docker image..." && \
docker build -t "$REPO_URI:$IMAGE_TAG" . && \
echo "Tagging Docker image..." && \
docker tag "$REPO_URI:$IMAGE_TAG" "$REPO_URI:$IMAGE_TAG" && \
echo "Pushing Docker image..." && \
docker push "$REPO_URI:$IMAGE_TAG" && \
echo "Docker image build & push completed successfully!"
EOT
  }

  triggers = {
    dockerfile_md5 = filemd5("Dockerfile")
    app_md5        = filemd5("app.py")
    req_md5        = filemd5("requirements.txt")
    image_tag      = var.repo_image_tag
  }
}





