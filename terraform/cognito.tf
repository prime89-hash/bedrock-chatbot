resource "aws_cognito_user_pool" "bedrock_user_pool" {
  name = "bedrock-chatbot-users"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  tags = {
    Name = "bedrock-chatbot-user-pool"
  }
}

resource "aws_cognito_user_pool_client" "bedrock_client" {
  name         = "bedrock-chatbot-client"
  user_pool_id = aws_cognito_user_pool.bedrock_user_pool.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]
  callback_urls                        = ["https://${aws_alb.bedrock_alb.dns_name}/oauth2/idpresponse"]
  logout_urls                          = ["https://${aws_alb.bedrock_alb.dns_name}/"]

  supported_identity_providers = ["COGNITO"]
  
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "bedrock_domain" {
  domain       = "bedrock-chatbot-${random_string.domain_suffix.result}"
  user_pool_id = aws_cognito_user_pool.bedrock_user_pool.id
}

resource "random_string" "domain_suffix" {
  length  = 8
  special = false
  upper   = false
}
