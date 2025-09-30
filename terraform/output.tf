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

output "user_creation_command" {
  description = "Command to create a user"
  value = "aws cognito-idp admin-create-user --user-pool-id ${aws_cognito_user_pool.bedrock_user_pool.id} --username admin --user-attributes Name=email,Value=admin@example.com --temporary-password TempPass123! --region ${var.aws_region}"
}

output "ecs_repository_url" {
  value = aws_ecr_repository.chatbot_repository.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.bedrock_ecs_main.name
}
