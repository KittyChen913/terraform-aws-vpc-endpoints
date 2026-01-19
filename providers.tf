# EC2 Terraform 配置文件

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 連接到 AWS 指定 region，使用指定 profile
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
