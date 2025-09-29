output "alb_dns_name" {
  value = aws_alb.bedrock_alb.dns_name
}

output "ecs_repository_url" {
  value = aws_ecr_repository.chatbot_repository.repository_url

}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.bedrock_ecs_main.name
}
