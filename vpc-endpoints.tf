# ============================================================================
# S3 VPC Gateway Endpoint
# ============================================================================

# VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}

# ============================================================================
# VPC Endpoint Policy for S3
# ============================================================================

# VPC Endpoint Policy：允許所有 S3 訪問
resource "aws_vpc_endpoint_policy" "s3_gateway" {
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway.id

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

# ============================================================================
# Lambda VPC Interface Endpoint
# ============================================================================

# Security Group：用於 VPC Endpoints
resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

# VPC Interface Endpoint：用於 Lambda
resource "aws_vpc_endpoint" "lambda_interface" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.lambda"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_subnet.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoint.id
  ]

  tags = {
    Name = "lambda-interface-endpoint"
  }
}

# ============================================================================
# VPC Endpoint Policy for Lambda
# ============================================================================

# VPC Endpoint Policy：允許所有 Lambda 訪問
resource "aws_vpc_endpoint_policy" "lambda_interface" {
  vpc_endpoint_id = aws_vpc_endpoint.lambda_interface.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "lambda:GetFunctionConfiguration",
          "lambda:InvokeAsync"
        ]
        Resource = "*"
      }
    ]
  })
}
