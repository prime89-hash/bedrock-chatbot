resource "aws_security_group" "alb_sg" {
  name        = "bedrock_alb_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.bedrock_main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "bedrock_alb_sg"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "bedrock_ecs_sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.bedrock_main.id
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bedrock_ecs_sg"
  }
}

resource "aws_alb" "bedrock_alb" {
  name                       = "bedrock-alb"
  internal                   = false
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = aws_subnet.public_subnet.*.id
  enable_deletion_protection = false
  tags = {
    Name = "bedrock_alb"
  }
}

resource "aws_alb_target_group" "bedrock_chatbot_tg" {
  name        = "bedrock-chatbot-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.bedrock_main.id
  target_type = "ip"
  
  health_check {
    path                = "/?health=check"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
    protocol            = "HTTP"
  }
  
  tags = {
    Name = "bedrock_chatbot_tg"
  }
}

# HTTPS listener with Cognito authentication
resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = aws_alb.bedrock_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.bedrock_self_signed.arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.bedrock_user_pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.bedrock_client.id
      user_pool_domain    = aws_cognito_user_pool_domain.bedrock_domain.domain
      on_unauthenticated_request = "authenticate"
    }
  }
}

# Listener rule to forward after authentication
resource "aws_alb_listener_rule" "forward_after_auth" {
  listener_arn = aws_alb_listener.alb_listener_https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.bedrock_chatbot_tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# HTTP listener redirects to HTTPS
resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = aws_alb.bedrock_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}