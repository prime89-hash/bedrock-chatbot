# Secure Network Flow

## Inbound Traffic
```
Internet → Route53 → ALB (Public Subnet) → Cognito Auth → ECS (Private Subnet)
```

## Outbound Traffic (Bedrock API)
```
ECS (Private Subnet) → VPC Endpoint → Bedrock Service
```

## Security Layers
1. **DNS**: Route53 resolves domain to ALB
2. **SSL**: Certificate validates at ALB
3. **Auth**: Cognito validates user identity
4. **Network**: Private subnets isolate containers
5. **VPC Endpoint**: Private AWS service access
6. **IAM**: Task role limits Bedrock permissions

## Port Flow
- **443**: Internet → ALB (HTTPS)
- **80**: Internet → ALB → Redirect to 443
- **8501**: ALB → ECS Container
- **443**: ECS → VPC Endpoint → Bedrock
