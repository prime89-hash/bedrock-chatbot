# 🤖 Secure Bedrock Chatbot

Enterprise-grade chatbot powered by Claude Sonnet 4 with comprehensive security features.

## 🔒 Security Features

- ✅ **Cognito Authentication** - User authentication with MFA
- ✅ **Private Network** - ECS tasks in private subnets
- ✅ **VPC Endpoints** - Private AWS service communication
- ✅ **IAM Restrictions** - Least privilege access
- ✅ **Network Isolation** - Security groups and NACLs

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured
- Terraform installed
- Docker installed
- GitHub repository with secrets configured

### 1. Deploy Infrastructure

```bash
# Clone repository
git clone <your-repo-url>
cd bedrock-chatbot

# Deploy with Terraform
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Build and Deploy Application

```bash
# Build Docker image
docker build -t bedrock-chatbot .

# Get ECR URI
ECR_URI=$(terraform -chdir=terraform output -raw ecs_repository_url)

# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_URI

# Push image
docker tag bedrock-chatbot:latest $ECR_URI:latest
docker push $ECR_URI:latest

# Update ECS service
aws ecs update-service --cluster bedrock-ecs-cluster --service bedrock-chatbot-service --force-new-deployment --region us-west-2
```

### 3. Create Users

```bash
# Make script executable
chmod +x scripts/manage-users.sh

# Create a user
./scripts/manage-users.sh create admin@company.com TempPass123! SecurePass123!

# List users
./scripts/manage-users.sh list
```

### 4. Access Application

```bash
# Get application URL
terraform -chdir=terraform output application_url
```

Visit the URL, authenticate with Cognito, and start chatting!

## 🔧 GitHub Actions Pipeline

The repository includes automated CI/CD pipeline that:

1. **Validates** Terraform configuration
2. **Deploys** infrastructure changes
3. **Builds** Docker image
4. **Pushes** to ECR
5. **Updates** ECS service
6. **Waits** for deployment completion

### Required GitHub Secrets

```
AWS_ACCESS_KEY_ID     - AWS access key
AWS_SECRET_ACCESS_KEY - AWS secret key
```

## 📁 Project Structure

```
bedrock-chatbot/
├── app.py                 # Main Streamlit application
├── Dockerfile            # Container configuration
├── requirements.txt      # Python dependencies
├── terraform/           # Infrastructure as Code
│   ├── alb.tf           # Load balancer configuration
│   ├── cognito.tf       # Authentication setup
│   ├── ecs.tf           # Container orchestration
│   ├── iam.tf           # Permissions
│   ├── vpc.tf           # Network configuration
│   ├── vpc_endpoints.tf # Private AWS connectivity
│   └── variables.tf     # Configuration variables
├── scripts/
│   └── manage-users.sh  # User management utility
└── .github/workflows/
    └── deploy.yml       # CI/CD pipeline
```

## 🌐 Architecture

```
Internet → ALB → Cognito Auth → ECS (Private) → VPC Endpoint → Bedrock
```

### Network Flow
- **Public Subnets**: ALB only
- **Private Subnets**: ECS tasks (no internet access)
- **NAT Gateway**: Outbound internet for ECS
- **VPC Endpoints**: Private AWS service access

## 🛠️ User Management

### Create User
```bash
./scripts/manage-users.sh create user@example.com TempPass123! SecurePass123!
```

### List Users
```bash
./scripts/manage-users.sh list
```

### Delete User
```bash
./scripts/manage-users.sh delete user@example.com
```

## 📊 Monitoring

### Check ECS Service
```bash
aws ecs describe-services --cluster bedrock-ecs-cluster --services bedrock-chatbot-service --region us-west-2
```

### View Logs
```bash
aws logs tail /aws/ecs/bedrock-chatbot --follow --region us-west-2
```

### Check ALB Health
```bash
aws elbv2 describe-target-health --target-group-arn <target-group-arn> --region us-west-2
```

## 🔍 Troubleshooting

### Common Issues

1. **ECS Tasks Not Starting**
   - Check IAM permissions
   - Verify VPC endpoints
   - Review CloudWatch logs

2. **Authentication Issues**
   - Verify Cognito configuration
   - Check callback URLs
   - Confirm user pool settings

3. **Bedrock Access Denied**
   - Ensure model access is granted
   - Verify IAM permissions
   - Check inference profile usage

## 🏗️ Customization

### Change Model
Update `model_id` in `app.py`:
```python
model_id = "us.anthropic.claude-3-5-sonnet-20241022-v2:0"
```

### Modify UI
Edit `app.py` Streamlit components:
```python
st.title("Your Custom Title")
st.sidebar.selectbox("Options", ["Option1", "Option2"])
```

### Update Infrastructure
Modify Terraform files in `terraform/` directory and run:
```bash
terraform plan
terraform apply
```

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📞 Support

For issues and questions:
- Create GitHub issue
- Check CloudWatch logs
- Review AWS documentation
