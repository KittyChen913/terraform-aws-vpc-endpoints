# ============================================================================
# S3 Bucket Configuration
# ============================================================================

resource "aws_s3_bucket" "private_bucket" {
  bucket        = "my-private-ec2-bucket-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "private-ec2-bucket"
  }
}

# ============================================================================
# S3 Bucket Public Access Block
# ============================================================================

# 阻止所有 public 存取
resource "aws_s3_bucket_public_access_block" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# S3 Bucket Policy
# ============================================================================

# 只允許 private subnet 的 EC2 訪問
resource "aws_s3_bucket_policy" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  # 確保 public access block 先被套用
  depends_on = [aws_s3_bucket_public_access_block.private_bucket]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyAccessNotFromSpecificVPCEndpoint"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.private_bucket.arn}",
          "${aws_s3_bucket.private_bucket.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.s3_gateway.id
          }
          ArnNotEquals = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.aws_profile}",
              "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/*"
            ]
          }
        }
      }
    ]
  })
}

# ============================================================================
# S3 Bucket Versioning
# ============================================================================

# 啟用版本控制
resource "aws_s3_bucket_versioning" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================================
# S3 Bucket Server-Side Encryption
# ============================================================================

# 啟用伺服器端加密
resource "aws_s3_bucket_server_side_encryption_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
