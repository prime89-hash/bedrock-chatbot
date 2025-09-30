output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value = aws_alb.bedrock_alb.dns_name
}

output "application_url" {
  description = "Application URL to access the chatbot"
  value = "http://${aws_alb.bedrock_alb.dns_name}"
}

output "ecs_repository_url" {
  value = aws_ecr_repository.chatbot_repository.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.bedrock_ecs_main.name
}

output "login_credentials" {
  description = "Login credentials for the application"
  value = "Password: SecurePass123!"
  sensitive = true
}
