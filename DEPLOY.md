# Simplified Secure Deployment

## Step 1: Deploy Infrastructure
```bash
cd /workshop/bedrock-chatbot/terraform
terraform init
terraform apply -auto-approve
```

## Step 2: Get Outputs
```bash
# Get ALB DNS name
terraform output application_url

# Get Cognito User Pool ID
terraform output cognito_user_pool_id
```

## Step 3: Build & Deploy App
```bash
cd /workshop/bedrock-chatbot

# Build image
docker build -t bedrock-chatbot .

# Get ECR URI from terraform output
ECR_URI=$(terraform -chdir=terraform output -raw ecs_repository_url)

# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_URI

# Tag and push
docker tag bedrock-chatbot:latest $ECR_URI:latest
docker push $ECR_URI:latest

# Update ECS service
aws ecs update-service --cluster bedrock-ecs-cluster --service bedrock-chatbot-service --force-new-deployment --region us-west-2
```

## Step 4: Create Users
```bash
USER_POOL_ID=$(terraform -chdir=terraform output -raw cognito_user_pool_id)

# Create user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --user-attributes Name=email,Value=testuser@example.com \
  --temporary-password TempPass123! \
  --message-action SUPPRESS \
  --region us-west-2

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --password SecurePass123! \
  --permanent \
  --region us-west-2
```

## Step 5: Access Application
1. Get URL: `terraform output application_url`
2. Visit the URL in browser
3. Login with created credentials
4. Set up MFA when prompted
5. Access the secure chatbot

## Security Features Enabled:
- ✅ Private subnets (no public IPs)
- ✅ Cognito authentication + MFA
- ✅ VPC endpoints for Bedrock
- ✅ Network isolation
- ✅ IAM role restrictions

## Access Flow:
```
User → ALB (HTTP) → Cognito Auth → ECS (Private) → Bedrock (VPC Endpoint)
```
