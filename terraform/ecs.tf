resource "aws_ecs_cluster" "bedrock_ecs_main" {
  name = "bedrock-ecs-cluster"

}

resource "aws_ecs_task_definition" "bedrock_chatbot_task" {
  family                   = "bedrock-chatbot-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "bedrock-chatbot-container"
      image     = "${aws_ecr_repository.chatbot_repository.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "BEDROCK_REGION"
          value = "eu-west-2"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.bedrock_chatbot_log_group.name
          "awslogs-region"        = "eu-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

}

resource "aws_ecs_service" "bedrock_chatbot_streamlit_service" {
  name            = "bedrock-chatbot-service"
  cluster         = aws_ecs_cluster.bedrock_ecs_main.id
  task_definition = aws_ecs_task_definition.bedrock_chatbot_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public_subnet.*.id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.bedrock_chatbot_tg.arn
    container_name   = "bedrock-chatbot-container"
    container_port   = var.container_port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy, aws_iam_role_policy_attachment.bedrock_attachment, aws_alb_listener.alb_listener]

}