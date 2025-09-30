resource "aws_iam_role" "ecs_task_execution_role" {
  name = "bedrockecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ECS Task Role (for Bedrock access)
resource "aws_iam_role" "ecs_bedrock_task_role" {
  name = "bedrockTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "bedrock_access_policy" {
  name        = "ClaudeSonnet4AccessPolicy"
  description = "Policy to allow ECS task to invoke Claude Sonnet 4"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:GetModel",
          "bedrock:DescribeModel"
        ]
        Resource = "arn:aws:bedrock:us-west-2::foundation-model/anthropic.claude-sonnet-4-20250514-v1:0"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListModels",
          "bedrock:ListFoundationModels"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_attachment" {
  role       = aws_iam_role.ecs_bedrock_task_role.name
  policy_arn = aws_iam_policy.bedrock_access_policy.arn
}



