# ============================================================================
# S3 VPC Gateway Endpoint
# ============================================================================

# VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name = "s3-vpc-endpoint"
  }
}

# ============================================================================
# VPC Endpoint Policy for S3
# ============================================================================

# VPC Endpoint Policy：允許所有 S3 訪問
resource "aws_vpc_endpoint_policy" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

