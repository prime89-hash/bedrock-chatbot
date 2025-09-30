# Secure Bedrock Chatbot - Complete Implementation Guide

## 📋 Overview

This guide provides step-by-step instructions to deploy a secure chatbot powered by Claude Sonnet 4 with enterprise-grade security features including ALB-level Cognito authentication, private networking, and VPC endpoints.

## 🏗️ Architecture

```
Internet → ALB (HTTPS) → Cognito Auth → ECS (Private) → VPC Endpoint → Bedrock
```

### Security Features
- ✅ ALB-level Cognito authentication with MFA support
- ✅ HTTPS encryption (self-signed certificate)
- ✅ Private subnets for compute resources
- ✅ VPC endpoints for AWS service communication
- ✅ IAM roles with least privilege access
- ✅ Automated user creation via GitHub Actions

## 🛠️ Prerequisites

### Required Tools
- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.0
- Docker
- Git
- GitHub account

### AWS Permissions Required
- EC2, ECS, ALB, VPC management
- Cognito User Pool management
- ECR repository access
- Bedrock model access
- IAM role creation
- ACM certificate management

## 📁 Project Structure

```
bedrock-chatbot/
├── .github/workflows/
│   └── deploy.yml              # CI/CD pipeline
├── terraform/
│   ├── alb.tf                  # Load balancer + Cognito auth
│   ├── cloudwatch.tf           # Logging configuration
│   ├── cognito.tf              # User pool and client
│   ├── ecr.tf                  # Container registry
│   ├── ecs.tf                  # Container orchestration
│   ├── iam.tf                  # Permissions and roles
│   ├── output.tf               # Terraform outputs
│   ├── provider.tf             # AWS provider config
│   ├── ssl.tf                  # Self-signed certificate
│   ├── terraform.tfvars        # Configuration variables
│   ├── variable.tf             # Variable definitions
│   └── vpc.tf                  # Network infrastructure
├── app.py                      # Streamlit chatbot application
├── Dockerfile                  # Container configuration
├── requirements.txt            # Python dependencies
└── README.md                   # Basic documentation
```

## 🚀 Step-by-Step Implementation

### Step 1: Repository Setup

1. **Clone or Fork Repository**
   ```bash
   git clone https://github.com/your-username/bedrock-chatbot.git
   cd bedrock-chatbot
   ```

2. **Configure GitHub Secrets**
   - Go to GitHub repository → Settings → Secrets and variables → Actions
   - Add required secrets:
     ```
     AWS_ROLE_ARN: arn:aws:iam::ACCOUNT-ID:role/GitHubActionsRole
     ```

3. **Setup AWS OIDC Role** (if not exists)
   ```bash
   # Create OIDC identity provider and role for GitHub Actions
   # This allows GitHub to assume AWS roles without storing credentials
   ```

### Step 2: Infrastructure Configuration

1. **Review Terraform Variables**
   ```bash
   cd terraform
   cat terraform.tfvars
   ```
   
   Default configuration:
   ```hcl
   aws_region = "us-west-2"
   image_tag = "latest"
   container_port = 8501
   ```

2. **Customize Configuration** (optional)
   - Modify `terraform.tfvars` for different regions or settings
   - Update `variable.tf` for additional customization

### Step 3: Deploy Infrastructure

#### Option A: Automated Deployment (Recommended)

1. **Push to Main Branch**
   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

2. **Monitor GitHub Actions**
   - Go to GitHub repository → Actions tab
   - Watch the deployment progress
   - Deployment includes:
     - Infrastructure creation
     - Docker image build and push
     - ECS service deployment
     - Automatic user creation

#### Option B: Manual Deployment

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Deploy Infrastructure**
   ```bash
   terraform apply -auto-approve
   ```

3. **Build and Push Docker Image**
   ```bash
   cd ..
   
   # Get ECR repository URL
   ECR_URI=$(terraform -chdir=terraform output -raw ecs_repository_url)
   
   # Login to ECR
   aws ecr get-login-password --region us-west-2 | \
     docker login --username AWS --password-stdin $ECR_URI
   
   # Build and push image
   docker build -t bedrock-chatbot .
   docker tag bedrock-chatbot:latest $ECR_URI:latest
   docker push $ECR_URI:latest
   ```

4. **Update ECS Service**
   ```bash
   aws ecs update-service \
     --cluster bedrock-ecs-cluster \
     --service bedrock-chatbot-service \
     --force-new-deployment \
     --region us-west-2
   ```

### Step 4: Access Application

1. **Get Application URL**
   ```bash
   cd terraform
   terraform output application_url
   ```
   
   Example output: `https://bedrock-alb-xxxxxxxxx.us-west-2.elb.amazonaws.com`

2. **Get Login Credentials**
   - **Username**: `admin`
   - **Password**: `Admin123!`
   
   (Automatically created by GitHub Actions deployment)

3. **Access the Application**
   - Open the HTTPS URL in your browser
   - Accept the security warning (self-signed certificate)
   - Login with the credentials above
   - Start chatting with Claude Sonnet 4!

### Step 5: User Management

#### Create Additional Users

```bash
# Get User Pool ID
USER_POOL_ID=$(terraform -chdir=terraform output -raw cognito_user_pool_id)

# Create new user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username newuser \
  --user-attributes Name=email,Value=newuser@example.com Name=email_verified,Value=true \
  --message-action SUPPRESS \
  --region us-west-2

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username newuser \
  --password NewUser123! \
  --permanent \
  --region us-west-2

# Confirm user
aws cognito-idp admin-confirm-sign-up \
  --user-pool-id $USER_POOL_ID \
  --username newuser \
  --region us-west-2
```

#### List Existing Users

```bash
aws cognito-idp list-users \
  --user-pool-id $USER_POOL_ID \
  --region us-west-2
```

#### Delete User

```bash
aws cognito-idp admin-delete-user \
  --user-pool-id $USER_POOL_ID \
  --username username \
  --region us-west-2
```

## 🔧 Configuration Details

### Cognito Authentication

- **User Pool**: Manages user accounts and authentication
- **MFA Support**: Can be enabled in Cognito console
- **Password Policy**: 8+ characters, mixed case, numbers
- **OAuth Flows**: Authorization code grant for ALB integration

### Network Security

- **VPC**: Isolated network (10.0.0.0/16)
- **Public Subnets**: ALB only (10.0.1.0/24, 10.0.2.0/24)
- **Private Subnets**: ECS tasks (10.0.3.0/24, 10.0.4.0/24)
- **NAT Gateways**: Outbound internet access for private subnets
- **Security Groups**: Restrictive ingress/egress rules

### Container Configuration

- **Base Image**: python:3.11-slim
- **Application**: Streamlit chatbot
- **Health Checks**: Custom endpoint for ALB monitoring
- **Resources**: 0.5 vCPU, 1GB RAM (configurable)

### AI Model Configuration

- **Model**: Claude Sonnet 4 (us.anthropic.claude-sonnet-4-20250514-v1:0)
- **API**: Bedrock Converse API
- **Parameters**: Temperature 0.9, Max tokens 2000
- **Languages**: English, Spanish, French support

## 📊 Monitoring and Troubleshooting

### Check Deployment Status

```bash
# ECS Service Status
aws ecs describe-services \
  --cluster bedrock-ecs-cluster \
  --services bedrock-chatbot-service \
  --region us-west-2

# ALB Target Health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --region us-west-2

# View Application Logs
aws logs tail /aws/ecs/bedrock-chatbot --follow --region us-west-2
```

### Common Issues and Solutions

#### 1. "Not Secure" Browser Warning
- **Cause**: Self-signed SSL certificate
- **Solution**: Click "Advanced" → "Proceed to site"
- **Production Fix**: Use real domain with validated ACM certificate

#### 2. User Login Issues
- **Check**: User exists and is confirmed
- **Fix**: Run user creation commands from Step 5
- **Verify**: User status in Cognito console

#### 3. ECS Tasks Not Starting
- **Check**: CloudWatch logs for error messages
- **Common Causes**: IAM permissions, VPC configuration, image issues
- **Fix**: Review logs and adjust configuration

#### 4. Bedrock Access Denied
- **Check**: IAM role has Bedrock permissions
- **Verify**: Model access is granted in Bedrock console
- **Region**: Ensure using supported region (us-west-2)

## 💰 Cost Estimation

### Monthly Costs (Approximate)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| ECS Fargate | 0.5 vCPU, 1GB RAM | ~$15 |
| NAT Gateway | 2 instances | ~$90 |
| Application Load Balancer | Standard ALB | ~$20 |
| VPC Endpoints | Interface endpoints | ~$22 |
| ECR Storage | 1GB | ~$0.10 |
| CloudWatch Logs | 10GB | ~$5 |
| **Total (excluding Bedrock)** | | **~$150-200** |

### Bedrock Costs (Pay-per-use)
- **Input tokens**: $0.003 per 1K tokens
- **Output tokens**: $0.015 per 1K tokens
- **Typical conversation**: $0.01-0.05 per exchange

## 🔄 CI/CD Pipeline

### Automated Deployment
- **Trigger**: Push to main branch
- **Steps**: Infrastructure → Build → Deploy → User Creation
- **Duration**: ~10-15 minutes

### Manual Operations
- **Destroy**: GitHub Actions → Run workflow → Set destroy=true
- **Redeploy**: Push changes or manual trigger

## 🔒 Security Best Practices

### Implemented
- ✅ Private subnets for compute
- ✅ VPC endpoints for AWS services
- ✅ IAM roles with minimal permissions
- ✅ Cognito authentication
- ✅ HTTPS encryption
- ✅ Security groups with restrictive rules

### Additional Recommendations
- 🔄 Enable MFA in Cognito
- 🔄 Use AWS WAF for additional protection
- 🔄 Enable GuardDuty for threat detection
- 🔄 Implement backup strategies
- 🔄 Use real domain with validated SSL

## 🚀 Production Considerations

### Scalability
- **Auto Scaling**: Configure ECS service auto-scaling
- **Load Balancing**: ALB handles multiple ECS tasks
- **Database**: Add RDS for conversation history
- **Caching**: Implement ElastiCache for performance

### High Availability
- **Multi-AZ**: Already implemented (2 AZs)
- **Health Checks**: ALB monitors application health
- **Failover**: ECS automatically replaces failed tasks

### Security Enhancements
- **Real SSL**: Use validated ACM certificate with custom domain
- **WAF**: Add Web Application Firewall
- **Secrets**: Use AWS Secrets Manager for sensitive data
- **Compliance**: Implement logging and audit trails

## 📞 Support and Maintenance

### Regular Tasks
- **Monitor**: CloudWatch metrics and logs
- **Update**: Container images and dependencies
- **Backup**: Export Cognito user data
- **Scale**: Adjust ECS task count based on usage

### Troubleshooting Resources
- **CloudWatch Logs**: Application and infrastructure logs
- **AWS Console**: Service status and configuration
- **GitHub Actions**: Deployment history and logs
- **Terraform State**: Infrastructure state management

## 🎉 Conclusion

You now have a fully functional, secure chatbot with:
- **Enterprise Authentication**: Cognito with MFA support
- **Private Networking**: Isolated compute environment
- **AI Integration**: Claude Sonnet 4 via Bedrock
- **Automated Deployment**: GitHub Actions CI/CD
- **Production Ready**: Scalable and maintainable architecture

The implementation provides a solid foundation that can be extended with additional features like conversation history, user management interfaces, and advanced security controls.

---

**Document Version**: 1.0  
**Last Updated**: September 30, 2025  
**Implementation Status**: Complete and Tested
