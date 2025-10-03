terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "tf-backend-tf-module-for-github-jira-aws-lambda"
    key    = "lab/terraform.tfstate"
    region = "ap-south-1"

  }
}

provider "aws" {
  region = var.region
}

