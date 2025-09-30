output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value = aws_alb.bedrock_alb.dns_name
}

output "application_url" {
  description = "Application URL to access the chatbot (HTTPS)"
  value = "https://${aws_alb.bedrock_alb.dns_name}"
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value = aws_cognito_user_pool.bedrock_user_pool.id
}

output "cognito_domain" {
  description = "Cognito Domain for authentication"
  value = "${aws_cognito_user_pool_domain.bedrock_domain.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "default_user_credentials" {
  description = "Default user credentials"
  value = "Username: admin, Password: TempPass123!"
  sensitive = true
}

output "ecs_repository_url" {
  value = aws_ecr_repository.chatbot_repository.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.bedrock_ecs_main.name
}
