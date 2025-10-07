terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "food-delivery-terraform-state"
    key            = "ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "823741291200"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "food-delivery"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "image_retention_count" {
  description = "Number of images to retain"
  type        = number
  default     = 10
}

locals {
  repositories = {
    admin    = "food-admin"
    backend  = "food-backend"
    frontend = "food-frontend"
  }
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ECR Repositories
resource "aws_ecr_repository" "repos" {
  for_each = local.repositories
  
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name        = each.value
      Service     = each.key
    }
  )
}

# Lifecycle policies to prevent unlimited image accumulation
resource "aws_ecr_lifecycle_policy" "repos_policy" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.image_retention_count} images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Repository policy for GitHub OIDC role access
resource "aws_ecr_repository_policy" "github_access" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGitHubOIDCPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:role/github-oidc-food-delivery-ecr"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Outputs
output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value = {
    for k, v in aws_ecr_repository.repos : k => v.repository_url
  }
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs"
  value = {
    for k, v in aws_ecr_repository.repos : k => v.arn
  }
}

output "ecr_admin_repo" {
  description = "Admin repository name"
  value       = aws_ecr_repository.repos["admin"].name
}

output "ecr_backend_repo" {
  description = "Backend repository name"
  value       = aws_ecr_repository.repos["backend"].name
}

output "ecr_frontend_repo" {
  description = "Frontend repository name"
  value       = aws_ecr_repository.repos["frontend"].name
}

output "registry_url" {
  description = "ECR registry URL"
  value       = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}