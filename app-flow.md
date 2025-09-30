# Application Execution Flow

## 1. User Authentication
```
User → ALB → Cognito → JWT Token → ALB → ECS
```

## 2. Streamlit Application
```
ECS Container runs: streamlit run app.py --server.port 8501
```

## 3. User Interaction
```
User submits question → Streamlit form → query_bedrock() function
```

## 4. Bedrock API Call
```python
# In Private Subnet
bedrock_client = boto3.client('bedrock-runtime', region_name='us-west-2')
response = bedrock_client.converse(
    modelId='us.anthropic.claude-sonnet-4-20250514-v1:0',
    messages=[{'role': 'user', 'content': [{'text': user_question}]}]
)
```

## 5. Response Flow
```
Bedrock → VPC Endpoint → ECS → ALB → User Browser
```

## 6. Security Checkpoints
- ✅ HTTPS encryption
- ✅ Cognito JWT validation
- ✅ IAM role permissions
- ✅ VPC network isolation
- ✅ Security group restrictions
