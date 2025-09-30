# Self-signed certificate for ALB DNS (development/demo use)
resource "tls_private_key" "bedrock_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "bedrock_cert_self" {
  private_key_pem = tls_private_key.bedrock_key.private_key_pem

  subject {
    common_name = "bedrock-chatbot.local"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "bedrock_self_signed" {
  private_key      = tls_private_key.bedrock_key.private_key_pem
  certificate_body = tls_self_signed_cert.bedrock_cert_self.cert_pem

  tags = {
    Name = "bedrock-self-signed-cert"
  }
}
