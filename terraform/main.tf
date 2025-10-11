terraform {
  required_version = ">= 1.5.7"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configure your S3 backend - change the bucket name
  backend "s3" {
    bucket         = "food-delivery-terraform-state"  # CHANGE THIS
    key            = "food-delivery/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

# Keep your existing ECR repositories configuration here
# (your current ECR terraform code stays unchanged)