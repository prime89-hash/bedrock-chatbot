resource "aws_cloudwatch_log_group" "bedrock_chatbot_log_group" {
  name              = "/ecs/bedrock-chatbot"
  retention_in_days = 7

  tags = {
    Name = "bedrock_chatbot_log_group"
  }

}

resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/aws/vpc/flowlogs"
  retention_in_days = 14

  tags = {
    Name = "bedrock-vpc-flow-logs"
  }
}