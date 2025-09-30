resource "aws_cognito_user_pool" "bedrock_user_pool" {
  name = "bedrock-chatbot-users"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
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
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = ["https://${aws_alb.bedrock_alb.dns_name}/oauth2/idpresponse"]
  logout_urls                          = ["https://${aws_alb.bedrock_alb.dns_name}/"]

  supported_identity_providers = ["COGNITO"]
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

# Create a default user
resource "aws_cognito_user_pool_user" "default_user" {
  user_pool_id = aws_cognito_user_pool.bedrock_user_pool.id
  username     = "admin"

  attributes = {
    email          = "admin@example.com"
    email_verified = true
  }

  password = "TempPass123!"

  lifecycle {
    ignore_changes = [password]
  }
}
