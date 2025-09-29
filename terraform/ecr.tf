resource "aws_ecr_repository" "chatbot_repository" {
  name                 = "streamlit-bedrock-chatbot"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "name" = "strelit-bedrock-chatbot-ecr"
  }
}

