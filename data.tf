# ============================================================================
# Data Sources
# ============================================================================

# 取得當前 AWS Account ID
data "aws_caller_identity" "current" {}

# 自動讀取最新的 Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 獲取所有可用的 AZ
data "aws_availability_zones" "available" {
  state = "available"
}
