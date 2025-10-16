# Secure Bedrock Chatbot

Enterprise chatbot powered by Claude Sonnet 4 with private network security.

## Quick Deploy

```bash
# 1. Deploy infrastructure
cd terraform
terraform init
terraform apply -auto-approve

# 2. Build and push image
docker build -t bedrock-chatbot .
ECR_URI=$(terraform output -raw ecs_repository_url)
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $ECR_URI
docker tag bedrock-chatbot:latest $ECR_URI:latest
docker push $ECR_URI:latest

# 3. Update ECS service
aws ecs update-service --cluster bedrock-ecs-cluster --service bedrock-chatbot-service --force-new-deployment --region eu-west-2

# 4. Get URL
terraform output application_url
```

## Access

- **URL**: From terraform output
- **Password**: `SecurePass123!`

## Architecture

- **Security**: Private subnets, VPC endpoints, password auth
- **AI**: Claude Sonnet 4 via Bedrock
- **Infrastructure**: ECS Fargate, ALB, VPC
- **CI/CD**: GitHub Actions automated deployment