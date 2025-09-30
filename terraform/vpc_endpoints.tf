resource "aws_vpc_endpoint" "bedrock" {
  vpc_id              = aws_vpc.bedrock_main.id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_subnet.*.id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "bedrock-vpc-endpoint"
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "bedrock-vpc-endpoint-sg"
  description = "Security group for Bedrock VPC endpoint"
  vpc_id      = aws_vpc.bedrock_main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
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
