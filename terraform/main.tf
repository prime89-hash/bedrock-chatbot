module "github_oidc" {
  source        = "./modules/github_oidc"
  github_repo   = "prime89-hash/chatbot_infra"           
  github_branch = "main"                         
  role_name     = "github-actions-deploy-role"
  policy_arn    = "arn:aws:iam::aws:policy/AdministratorAccess"
}
