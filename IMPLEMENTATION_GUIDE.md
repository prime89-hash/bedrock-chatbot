# Secure Bedrock Chatbot - Complete Implementation Guide

## 📋 Overview

This guide provides step-by-step instructions to deploy a secure chatbot powered by Claude Sonnet 4 with enterprise-grade security features including ALB-level Cognito authentication, private networking, and secure AWS service communication.

## 🏗️ Current Architecture

```
Internet → ALB (HTTPS + Cognito Auth) → ECS Fargate (Private) → NAT Gateway → Bedrock API
                ↓
        Cognito User Pool
        (MFA Support)
```

### Security Features
- ✅ ALB-level Cognito authentication with strong password policy
- ✅ HTTPS encryption (self-signed certificate for development)
- ✅ Private subnets for all compute resources
- ✅ NAT Gateway for secure outbound internet access
- ✅ IAM roles with Bedrock-specific permissions
- ✅ Input validation and XSS protection
- ✅ Automated user creation via GitHub Actions
- ✅ VPC endpoints ready (currently disabled for troubleshooting)

## 🔐 AWS Account Requirements

### Required AWS Services Access

#### **Core Compute & Networking**
- **Amazon VPC**: Create VPCs, subnets, route tables, internet gateways
- **Amazon ECS**: Create clusters, services, task definitions
- **AWS Fargate**: Launch containerized applications
- **Elastic Load Balancing (ALB)**: Create and configure application load balancers
- **Amazon ECR**: Create repositories, push/pull container images

#### **AI & Machine Learning**
- **Amazon Bedrock**: 
  - Access to Claude Sonnet 4 model (`us.anthropic.claude-sonnet-4-20250514-v1:0`)
  - InvokeModel and Converse API permissions
  - Model access must be granted in Bedrock console

#### **Security & Authentication**
- **Amazon Cognito**: Create user pools, clients, domains
- **AWS Certificate Manager (ACM)**: Create and manage SSL certificates
- **AWS IAM**: Create roles, policies, and service-linked roles

#### **Monitoring & Logging**
- **Amazon CloudWatch**: Create log groups, view logs and metrics
- **AWS CloudTrail**: Optional for audit logging

#### **Optional (for enhanced security)**
- **VPC Endpoints**: Interface and Gateway endpoints for private AWS service access
- **AWS WAF**: Web application firewall protection
- **Amazon GuardDuty**: Threat detection service

### Required IAM Permissions

#### **For Deployment User/Role**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "ecs:*",
        "ecr:*",
        "elasticloadbalancing:*",
        "cognito-idp:*",
        "acm:*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetRole",
        "iam:GetPolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:PassRole",
        "logs:*",
        "bedrock:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### **For GitHub Actions OIDC Role**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-USERNAME/bedrock-chatbot:*"
        }
      }
    }
  ]
}
```

## 🚀 Step-by-Step Setup for New AWS Account

### Step 1: AWS Account Preparation

#### **1.1 Enable Required Services**
```bash
# Check if Bedrock is available in your region
aws bedrock list-foundation-models --region eu-west-2

# Enable Bedrock model access (must be done in console)
# Go to AWS Bedrock Console → Model Access → Request Access for Claude models
```

#### **1.2 Create OIDC Identity Provider**
```bash
# Create OIDC provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

#### **1.3 Create GitHub Actions Role**
```bash
# Create role for GitHub Actions
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://github-trust-policy.json

# Attach necessary policies
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### Step 2: Repository Configuration

#### **2.1 Fork/Clone Repository**
```bash
git clone https://github.com/your-username/bedrock-chatbot.git
cd bedrock-chatbot
```

#### **2.2 Configure GitHub Secrets**
Go to GitHub repository → Settings → Secrets and variables → Actions

**Required Secrets:**
- `AWS_ROLE_ARN`: `arn:aws:iam::YOUR-ACCOUNT-ID:role/GitHubActionsRole`

**Optional Secrets:**
- `ADMIN_PASSWORD`: Custom admin password (default: `SecureAdmin2025!@#`)

#### **2.3 Update Configuration**
Edit `terraform/terraform.tfvars`:
```hcl
aws_region = "eu-west-2"  # Change if needed
image_tag = "latest"
container_port = 8501
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
```

### Step 3: Bedrock Model Access

#### **3.1 Request Model Access (Critical)**
1. Go to AWS Bedrock Console
2. Navigate to "Model Access" in left sidebar
3. Click "Request model access"
4. Select "Anthropic Claude Sonnet 4"
5. Submit request (may take a few minutes to approve)

#### **3.2 Verify Model Access**
```bash
aws bedrock list-foundation-models \
  --by-provider anthropic \
  --region eu-west-2 \
  --query 'modelSummaries[?contains(modelId, `claude-sonnet-4`)]'
```

### Step 4: Deploy Infrastructure

#### **4.1 Automated Deployment**
```bash
# Push to trigger deployment
git add .
git commit -m "Initial deployment for new AWS account"
git push origin main
```

#### **4.2 Monitor Deployment**
- Go to GitHub Actions tab
- Watch deployment progress
- Check for any permission errors

#### **4.3 Manual Deployment (Alternative)**
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 5: Post-Deployment Configuration

#### **5.1 Get Application URL**
```bash
cd terraform
terraform output application_url
```

#### **5.2 Create Admin User (if not auto-created)**
```bash
USER_POOL_ID=$(terraform output -raw cognito_user_pool_id)

aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username admin \
  --user-attributes Name=email,Value=admin@example.com Name=email_verified,Value=true \
  --message-action SUPPRESS \
  --region eu-west-2

aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username admin \
  --password "SecureAdmin2025!@#" \
  --permanent \
  --region eu-west-2

aws cognito-idp admin-confirm-sign-up \
  --user-pool-id $USER_POOL_ID \
  --username admin \
  --region eu-west-2
```

## 🔧 Configuration Details

### Current Network Architecture

- **VPC**: 10.0.0.0/16 (isolated network)
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24 (ALB only)
- **Private Subnets**: 10.0.3.0/24, 10.0.4.0/24 (ECS tasks)
- **NAT Gateways**: 2 (one per AZ for high availability)
- **Internet Gateway**: Public subnet internet access

### Security Configuration

#### **Cognito User Pool Settings**
- **Password Policy**: 12+ characters, mixed case, numbers, symbols required
- **MFA**: Available (can be enabled per user)
- **Admin Creation**: Only admins can create users
- **Token Validity**: 1 hour access tokens, 7 days refresh tokens

#### **IAM Roles**
- **ECS Execution Role**: Pull images from ECR, write logs
- **ECS Task Role**: Access Bedrock APIs only
- **Least Privilege**: Minimal permissions for each service

#### **Network Security**
- **Security Groups**: Restrictive rules (ALB → ECS → NAT → Internet)
- **Private Subnets**: No direct internet access
- **HTTPS Only**: HTTP redirects to HTTPS

### Container Configuration

- **Base Image**: python:3.11-slim
- **Resources**: 0.5 vCPU, 1GB RAM
- **Health Checks**: Custom endpoint for monitoring
- **Auto Scaling**: Can be configured based on CPU/memory

## 💰 Cost Analysis for New Account

### Monthly Costs (eu-west-2)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| ECS Fargate | 0.5 vCPU, 1GB, 24/7 | ~$15 |
| NAT Gateway | 2 instances | ~$90 |
| Application Load Balancer | Standard ALB | ~$20 |
| ECR Storage | 1GB | ~$0.10 |
| CloudWatch Logs | 10GB retention | ~$5 |
| Cognito User Pool | <50K MAU | Free |
| **Infrastructure Total** | | **~$130** |

### Bedrock Costs (Pay-per-use)
- **Claude Sonnet 4**: 
  - Input: $0.003 per 1K tokens
  - Output: $0.015 per 1K tokens
- **Typical conversation**: $0.01-0.05 per exchange
- **Monthly estimate**: $10-50 (depends on usage)

### **Total Monthly Cost**: ~$140-180

## 🔍 Troubleshooting Common Issues

### Authentication Issues

#### **Problem**: No login page appears
**Solutions**:
1. Check ALB listener configuration
2. Verify Cognito domain is accessible
3. Accept self-signed certificate warning

#### **Problem**: User login fails
**Solutions**:
1. Verify user exists and is confirmed
2. Check password meets policy requirements
3. Ensure user pool client configuration is correct

### Bedrock Connectivity Issues

#### **Problem**: "Technical difficulties" error
**Solutions**:
1. Verify Bedrock model access is granted
2. Check IAM permissions for ECS task role
3. Ensure region supports Claude Sonnet 4
4. Check CloudWatch logs for specific errors

#### **Problem**: Model access denied
**Solutions**:
```bash
# Check model access status
aws bedrock get-model-invocation-logging-configuration --region eu-west-2

# List available models
aws bedrock list-foundation-models --region eu-west-2
```

### Network Issues

#### **Problem**: ECS tasks not starting
**Solutions**:
1. Check security group rules
2. Verify NAT gateway configuration
3. Ensure private subnets have route to NAT
4. Check ECR permissions

#### **Problem**: Health check failures
**Solutions**:
1. Verify container port configuration
2. Check application startup logs
3. Ensure health check endpoint responds

## 🔒 Security Best Practices

### Implemented Security Controls

1. **Network Isolation**: Private subnets, security groups
2. **Authentication**: Cognito with strong password policy
3. **Encryption**: HTTPS for all traffic
4. **Access Control**: IAM roles with minimal permissions
5. **Input Validation**: XSS and injection protection
6. **Logging**: CloudWatch logs for monitoring

### Additional Security Recommendations

1. **Enable MFA**: For all Cognito users
2. **Use Real SSL**: Custom domain with validated certificate
3. **Add WAF**: Web application firewall protection
4. **Enable GuardDuty**: Threat detection
5. **VPC Endpoints**: Private AWS service communication (when stable)
6. **Backup Strategy**: Regular configuration backups

## 🚀 Production Considerations

### Scalability Enhancements

1. **Auto Scaling**: Configure ECS service auto-scaling
2. **Multi-Region**: Deploy in multiple AWS regions
3. **Database**: Add RDS for conversation history
4. **Caching**: Implement ElastiCache for performance

### High Availability

1. **Multi-AZ**: Already implemented (2 availability zones)
2. **Health Monitoring**: ALB health checks with automatic failover
3. **Backup**: Automated snapshots and configuration backups

### Compliance & Governance

1. **CloudTrail**: Enable for audit logging
2. **Config**: Monitor configuration compliance
3. **Secrets Manager**: Store sensitive configuration
4. **Tagging**: Implement consistent resource tagging

## 📞 Support & Maintenance

### Regular Maintenance Tasks

1. **Monitor**: CloudWatch metrics and alarms
2. **Update**: Container images and dependencies
3. **Backup**: Export Cognito user data
4. **Scale**: Adjust resources based on usage patterns

### Monitoring Setup

```bash
# View application logs
aws logs tail /aws/ecs/bedrock-chatbot --follow --region eu-west-2

# Check ECS service health
aws ecs describe-services --cluster bedrock-ecs-cluster --services bedrock-chatbot-service --region eu-west-2

# Monitor ALB metrics
aws cloudwatch get-metric-statistics --namespace AWS/ApplicationELB --metric-name RequestCount --dimensions Name=LoadBalancer,Value=app/bedrock-alb/xxx --start-time 2025-01-01T00:00:00Z --end-time 2025-01-01T01:00:00Z --period 300 --statistics Sum --region eu-west-2
```

## 🎉 Conclusion

This implementation provides a production-ready, secure chatbot solution that can be deployed in any AWS account with proper permissions. The architecture balances security, cost-effectiveness, and maintainability while providing enterprise-grade features.

**Key Success Factors**:
- Proper AWS account setup with required permissions
- Bedrock model access approval
- GitHub Actions configuration with OIDC
- Strong security controls and monitoring

The solution is designed to scale from development to production environments with minimal configuration changes.

---

**Document Version**: 2.0  
**Last Updated**: October 1, 2025  
**Architecture Status**: Production Ready with Enhanced Security
