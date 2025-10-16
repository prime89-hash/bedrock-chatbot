# AWS Account Setup Guide for Bedrock Chatbot

## 📋 Complete AWS Account Requirements

This document provides detailed requirements for setting up the Secure Bedrock Chatbot in a new AWS account.

## 🔐 Required AWS Permissions

### 1. Administrative Setup Permissions

#### **Initial Setup User/Role (One-time)**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:AttachRolePolicy",
        "iam:CreatePolicy",
        "iam:GetPolicy",
        "iam:TagRole",
        "iam:TagPolicy"
      ],
      "Resource": "*"
    }
  ]
}
```

#### **GitHub Actions Deployment Role**
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
        "logs:*",
        "bedrock:*",
        "iam:GetRole",
        "iam:GetPolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:PassRole",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:TagRole",
        "iam:TagPolicy"
      ],
      "Resource": [
        "arn:aws:iam::*:role/bedrock*",
        "arn:aws:iam::*:role/ecsTask*",
        "arn:aws:iam::*:policy/Bedrock*"
      ]
    }
  ]
}
```

### 2. Service-Specific Requirements

#### **Amazon Bedrock**
- **Model Access**: Must request access to Claude Sonnet 4 in Bedrock console
- **Regions**: Currently available in eu-west-2, us-east-1, eu-west-1
- **Permissions**: InvokeModel, Converse, ListFoundationModels

#### **Amazon ECS/Fargate**
- **Service Linked Roles**: Automatically created
- **Task Execution Role**: AmazonECSTaskExecutionRolePolicy
- **Task Role**: Custom Bedrock access policy

#### **Amazon Cognito**
- **User Pool Management**: Create, configure, manage users
- **Domain Management**: Create hosted UI domains
- **Client Configuration**: OAuth2 flow setup

#### **Elastic Load Balancing**
- **ALB Management**: Create, configure listeners
- **Target Groups**: Health check configuration
- **SSL Certificates**: ACM integration

#### **Amazon VPC**
- **Network Management**: VPC, subnets, route tables
- **Security Groups**: Ingress/egress rules
- **NAT Gateways**: Outbound internet access
- **VPC Endpoints**: Private AWS service access (optional)

## 🚀 Step-by-Step Account Setup

### Step 1: Initial AWS Account Configuration

#### **1.1 Enable Required Regions**
```bash
# Verify Bedrock availability
aws bedrock list-foundation-models --region eu-west-2
aws bedrock list-foundation-models --region us-east-1
```

#### **1.2 Request Bedrock Model Access**
1. **Login to AWS Console**
2. **Navigate to Bedrock Service**
3. **Go to "Model Access" section**
4. **Request access for:**
   - Anthropic Claude 3.5 Sonnet
   - Anthropic Claude Sonnet 4 (if available)
5. **Wait for approval** (usually immediate, can take up to 24 hours)

#### **1.3 Verify Model Access**
```bash
aws bedrock list-foundation-models \
  --by-provider anthropic \
  --region eu-west-2 \
  --query 'modelSummaries[?contains(modelId, `claude`)].[modelId,modelName]' \
  --output table
```

### Step 2: GitHub Actions OIDC Setup

#### **2.1 Create OIDC Identity Provider**
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com \
  --tags Key=Purpose,Value=GitHubActions Key=Project,Value=BedrockChatbot
```

#### **2.2 Create Trust Policy for GitHub Actions**
Create file `github-actions-trust-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR-ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
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

#### **2.3 Create GitHub Actions Role**
```bash
# Create the role
aws iam create-role \
  --role-name GitHubActionsBedrockRole \
  --assume-role-policy-document file://github-actions-trust-policy.json \
  --description "Role for GitHub Actions to deploy Bedrock Chatbot" \
  --tags Key=Purpose,Value=GitHubActions Key=Project,Value=BedrockChatbot

# Create custom policy for deployment
aws iam create-policy \
  --policy-name BedrockChatbotDeploymentPolicy \
  --policy-document file://deployment-policy.json \
  --description "Policy for deploying Bedrock Chatbot infrastructure"

# Attach the policy
aws iam attach-role-policy \
  --role-name GitHubActionsBedrockRole \
  --policy-arn arn:aws:iam::YOUR-ACCOUNT-ID:policy/BedrockChatbotDeploymentPolicy
```

### Step 3: Service Quotas and Limits

#### **3.1 Check Current Quotas**
```bash
# ECS Service quotas
aws service-quotas get-service-quota \
  --service-code ecs \
  --quota-code L-9EF96962 # Services per cluster

# Fargate quotas
aws service-quotas get-service-quota \
  --service-code fargate \
  --quota-code L-3032A538 # Fargate On-Demand vCPU resource count

# ALB quotas
aws service-quotas get-service-quota \
  --service-code elasticloadbalancing \
  --quota-code L-53EA6B1F # Application Load Balancers per Region
```

#### **3.2 Request Quota Increases (if needed)**
```bash
# Example: Request Fargate vCPU increase
aws service-quotas request-service-quota-increase \
  --service-code fargate \
  --quota-code L-3032A538 \
  --desired-value 100
```

### Step 4: Network Prerequisites

#### **4.1 Check Available AZs**
```bash
aws ec2 describe-availability-zones \
  --region eu-west-2 \
  --query 'AvailabilityZones[?State==`available`].[ZoneName,ZoneId]' \
  --output table
```

#### **4.2 Verify NAT Gateway Limits**
```bash
aws service-quotas get-service-quota \
  --service-code vpc \
  --quota-code L-FE5A380F # NAT gateways per Availability Zone
```

### Step 5: Security Configuration

#### **5.1 Enable CloudTrail (Recommended)**
```bash
aws cloudtrail create-trail \
  --name bedrock-chatbot-audit-trail \
  --s3-bucket-name your-cloudtrail-bucket \
  --include-global-service-events \
  --is-multi-region-trail \
  --enable-log-file-validation
```

#### **5.2 Configure AWS Config (Optional)**
```bash
aws configservice put-configuration-recorder \
  --configuration-recorder name=bedrock-chatbot-config,roleARN=arn:aws:iam::YOUR-ACCOUNT-ID:role/aws-config-role \
  --recording-group allSupported=true,includeGlobalResourceTypes=true
```

## 🔧 Environment-Specific Configurations

### Development Environment

#### **Minimal Permissions**
- Single AZ deployment allowed
- Reduced logging retention
- Basic monitoring only

#### **Cost Optimization**
```hcl
# terraform/terraform.tfvars for development
aws_region = "eu-west-2"
environment = "dev"
enable_nat_gateway = false  # Use single NAT for cost savings
log_retention_days = 7      # Shorter retention
desired_capacity = 1        # Single task
```

### Production Environment

#### **Enhanced Security**
- Multi-AZ deployment required
- Extended logging retention
- Enhanced monitoring and alerting

#### **High Availability Configuration**
```hcl
# terraform/terraform.tfvars for production
aws_region = "eu-west-2"
environment = "prod"
enable_nat_gateway = true   # Multi-AZ NAT gateways
log_retention_days = 90     # Extended retention
desired_capacity = 2        # Multiple tasks for HA
enable_vpc_endpoints = true # Private AWS service access
```

## 💰 Cost Planning

### Initial Setup Costs (One-time)
- **NAT Gateway**: $45/month per gateway
- **ALB**: $20/month base cost
- **ECS Fargate**: $15/month for 0.5 vCPU, 1GB RAM
- **CloudWatch Logs**: $5/month for 10GB
- **Total Base**: ~$85-130/month (depending on configuration)

### Usage-Based Costs
- **Bedrock Claude Sonnet 4**: $0.003 input + $0.015 output per 1K tokens
- **Data Transfer**: $0.09/GB outbound
- **Additional Storage**: $0.10/GB/month for ECR

### Cost Optimization Strategies

#### **Development**
- Use single AZ
- Reduce log retention
- Use smaller instance sizes
- Schedule resources (stop during off-hours)

#### **Production**
- Reserved capacity for predictable workloads
- Use Savings Plans for compute
- Implement auto-scaling
- Monitor and optimize regularly

## 🔍 Validation Checklist

### Pre-Deployment Validation

#### **✅ Account Setup**
- [ ] Bedrock model access approved
- [ ] GitHub Actions OIDC provider created
- [ ] Deployment role created with proper permissions
- [ ] Service quotas sufficient for deployment

#### **✅ Network Requirements**
- [ ] At least 2 AZs available in target region
- [ ] VPC CIDR doesn't conflict with existing networks
- [ ] NAT Gateway quotas available

#### **✅ Security Requirements**
- [ ] IAM roles follow least privilege principle
- [ ] CloudTrail enabled for audit logging
- [ ] Security groups configured restrictively

#### **✅ GitHub Configuration**
- [ ] Repository forked/cloned
- [ ] AWS_ROLE_ARN secret configured
- [ ] Optional ADMIN_PASSWORD secret set

### Post-Deployment Validation

#### **✅ Infrastructure Health**
```bash
# Check ECS service
aws ecs describe-services --cluster bedrock-ecs-cluster --services bedrock-chatbot-service

# Check ALB health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# Test Bedrock access
aws bedrock converse --model-id us.anthropic.claude-sonnet-4-20250514-v1:0 --messages '[{"role":"user","content":[{"text":"Hello"}]}]'
```

#### **✅ Application Access**
- [ ] HTTPS URL accessible
- [ ] Cognito login page appears
- [ ] Admin user can authenticate
- [ ] Chatbot responds to queries

## 📞 Support and Troubleshooting

### Common Setup Issues

#### **Bedrock Access Denied**
```bash
# Check model access status
aws bedrock list-foundation-models --region eu-west-2 --query 'modelSummaries[?contains(modelId, `claude-sonnet-4`)]'

# If empty, request access in Bedrock console
```

#### **GitHub Actions Permission Errors**
```bash
# Verify OIDC provider exists
aws iam get-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::YOUR-ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com

# Check role trust policy
aws iam get-role --role-name GitHubActionsBedrockRole --query 'Role.AssumeRolePolicyDocument'
```

#### **Service Quota Exceeded**
```bash
# List current quotas
aws service-quotas list-service-quotas --service-code ecs

# Request increase
aws service-quotas request-service-quota-increase --service-code ecs --quota-code L-9EF96962 --desired-value 20
```

### Getting Help

1. **AWS Support**: Use AWS Support Center for service-specific issues
2. **GitHub Issues**: Report deployment or configuration problems
3. **AWS Documentation**: Reference official AWS service documentation
4. **Community Forums**: AWS re:Post for community support

---

**Document Version**: 1.0  
**Last Updated**: October 1, 2025  
**Scope**: Complete AWS account setup for Bedrock Chatbot deployment
