# VPC Endpoints for secure AWS service communication
# Temporarily disabled for troubleshooting

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "bedrock-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.bedrock_main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bedrock-vpc-endpoint-sg"
  }
}

# Temporarily comment out VPC endpoints to test connectivity
# Uncomment after confirming basic functionality works

# # Bedrock Runtime VPC Endpoint
# resource "aws_vpc_endpoint" "bedrock_runtime" {
#   vpc_id              = aws_vpc.bedrock_main.id
#   service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnet[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "bedrock-runtime-endpoint"
#   }
# }

# # ECR API VPC Endpoint
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = aws_vpc.bedrock_main.id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnet[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ecr-api-endpoint"
#   }
# }

# # ECR Docker VPC Endpoint
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = aws_vpc.bedrock_main.id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnet[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "ecr-dkr-endpoint"
#   }
# }

# # CloudWatch Logs VPC Endpoint
# resource "aws_vpc_endpoint" "logs" {
#   vpc_id              = aws_vpc.bedrock_main.id
#   service_name        = "com.amazonaws.${var.aws_region}.logs"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private_subnet[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
#   private_dns_enabled = true

#   tags = {
#     Name = "logs-endpoint"
#   }
# }

# # S3 Gateway VPC Endpoint (for ECR layers)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.bedrock_main.id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = aws_route_table.private_rt[*].id

#   tags = {
#     Name = "s3-gateway-endpoint"
#   }
# }
