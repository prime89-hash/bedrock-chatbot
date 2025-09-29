output "alb_dns_name" {
  value = aws_alb.bedrock_alb.dns_name
}

output "ecs_repository_url" {
  value = aws_ecr_repository.chatbot_repository.repository_url

}

output "github_actions_role_arn" {
  value = module.github_oidc.role_arn
}
