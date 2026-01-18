# ============================================================================
# IAM Role and Instance Profile (S3 Full Access)
# ============================================================================

# IAM Role：給 EC2 Instance 使用，有 S3 全訪問權限
resource "aws_iam_role" "ec2_s3_full_access" {
  name = "ec2-s3-full-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ec2-s3-full-access-role"
  }
}

# 將 AWS 現有的 AmazonS3FullAccess Policy 附加到 IAM Role
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_s3_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 將 AWS 現有的 AWSLambda_FullAccess Policy 附加到 IAM Role
resource "aws_iam_role_policy_attachment" "lambda_full_access" {
  role       = aws_iam_role.ec2_s3_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Instance Profile：連接 IAM Role 到 EC2 Instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-full-access-profile"
  role = aws_iam_role.ec2_s3_full_access.name
}
