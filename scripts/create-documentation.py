#!/usr/bin/env python3
"""
Script to create comprehensive documentation in multiple formats
"""

import os
import sys
from datetime import datetime

def create_html_document():
    """Create HTML version of the documentation"""
    
    html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Bedrock Chatbot - Architecture Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8f9fa;
        }
        
        h1, h2, h3, h4, h5, h6 {
            color: #2c3e50;
            margin-top: 2em;
            margin-bottom: 1em;
        }
        
        h1 {
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            text-align: center;
        }
        
        h2 {
            border-bottom: 2px solid #e74c3c;
            padding-bottom: 8px;
        }
        
        h3 {
            border-left: 4px solid #f39c12;
            padding-left: 15px;
        }
        
        .architecture-box {
            background-color: white;
            border: 2px solid #3498db;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            font-family: monospace;
            white-space: pre;
            overflow-x: auto;
        }
        
        .service-info {
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .security-feature {
            background-color: #d5f4e6;
            border-left: 4px solid #27ae60;
            padding: 10px 15px;
            margin: 10px 0;
        }
        
        code {
            background-color: #f4f4f4;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        }
        
        pre {
            background-color: #2d3748;
            color: #e2e8f0;
            padding: 20px;
            border-radius: 8px;
            overflow-x: auto;
            margin: 20px 0;
        }
        
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
            background-color: white;
        }
        
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        
        th {
            background-color: #3498db;
            color: white;
        }
        
        .toc {
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .flow-step {
            background-color: #e8f4fd;
            border: 1px solid #3498db;
            border-radius: 5px;
            padding: 10px;
            margin: 5px 0;
            display: inline-block;
            min-width: 200px;
            text-align: center;
        }
        
        .arrow {
            text-align: center;
            font-size: 20px;
            color: #3498db;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <h1>🤖 Secure Bedrock Chatbot<br>Complete Architecture Documentation</h1>
    
    <div class="toc">
        <h2>📋 Table of Contents</h2>
        <ul>
            <li><a href="#executive-summary">1. Executive Summary</a></li>
            <li><a href="#architecture-overview">2. Architecture Overview</a></li>
            <li><a href="#service-components">3. Service Components</a></li>
            <li><a href="#security-implementation">4. Security Implementation</a></li>
            <li><a href="#execution-flow">5. Execution Flow</a></li>
            <li><a href="#deployment-pipeline">6. Deployment Pipeline</a></li>
            <li><a href="#cost-analysis">7. Cost Analysis</a></li>
            <li><a href="#troubleshooting">8. Troubleshooting Guide</a></li>
        </ul>
    </div>
    
    <h2 id="executive-summary">1. 📊 Executive Summary</h2>
    <div class="service-info">
        <p>The Secure Bedrock Chatbot is an enterprise-grade conversational AI solution built on AWS infrastructure. It leverages Amazon Bedrock's Claude Sonnet 4 model with comprehensive security controls including user authentication, network isolation, and private service communication.</p>
        
        <h3>🔑 Key Features</h3>
        <ul>
            <li><strong>AI Model:</strong> Claude Sonnet 4 via Amazon Bedrock</li>
            <li><strong>Authentication:</strong> AWS Cognito with MFA</li>
            <li><strong>Security:</strong> Private subnets, VPC endpoints, IAM controls</li>
            <li><strong>Scalability:</strong> ECS Fargate with auto-scaling</li>
            <li><strong>CI/CD:</strong> GitHub Actions automated deployment</li>
            <li><strong>Monitoring:</strong> CloudWatch logs and metrics</li>
        </ul>
    </div>
    
    <h2 id="architecture-overview">2. 🏗️ Architecture Overview</h2>
    <div class="architecture-box">
┌─────────────────────────────────────────────────────────────────┐
│                        INTERNET                                 │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                APPLICATION LOAD BALANCER                       │
│                    (Public Subnets)                           │
│  ┌─────────────────┐              ┌─────────────────┐         │
│  │   AZ-1a         │              │   AZ-1b         │         │
│  │ 10.0.1.0/24     │              │ 10.0.2.0/24     │         │
│  └─────────────────┘              └─────────────────┘         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                  COGNITO AUTHENTICATION                        │
│                     (User Pool)                               │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                    ECS FARGATE                                 │
│                  (Private Subnets)                            │
│  ┌─────────────────┐              ┌─────────────────┐         │
│  │   AZ-1a         │              │   AZ-1b         │         │
│  │ 10.0.3.0/24     │              │ 10.0.4.0/24     │         │
│  │ ┌─────────────┐ │              │ ┌─────────────┐ │         │
│  │ │ Streamlit   │ │              │ │ Streamlit   │ │         │
│  │ │ Container   │ │              │ │ Container   │ │         │
│  │ └─────────────┘ │              │ └─────────────┘ │         │
│  └─────────────────┘              └─────────────────┘         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                   VPC ENDPOINT                                 │
│                 (Interface Endpoint)                           │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                 AMAZON BEDROCK                                 │
│              (Claude Sonnet 4)                                │
└─────────────────────────────────────────────────────────────────┘
    </div>
    
    <h2 id="service-components">3. 🔧 Service Components</h2>
    
    <h3>🌐 Amazon VPC (Virtual Private Cloud)</h3>
    <div class="service-info">
        <p><strong>Purpose:</strong> Provides isolated network environment for all resources</p>
        <ul>
            <li><strong>CIDR Block:</strong> 10.0.0.0/16</li>
            <li><strong>Availability Zones:</strong> 2 (us-west-2a, us-west-2b)</li>
            <li><strong>Public Subnets:</strong> 10.0.1.0/24, 10.0.2.0/24 (ALB only)</li>
            <li><strong>Private Subnets:</strong> 10.0.3.0/24, 10.0.4.0/24 (ECS tasks)</li>
        </ul>
    </div>
    
    <h3>⚖️ Application Load Balancer (ALB)</h3>
    <div class="service-info">
        <p><strong>Purpose:</strong> Distributes incoming traffic and handles authentication</p>
        <ul>
            <li><strong>Type:</strong> Application Load Balancer</li>
            <li><strong>Scheme:</strong> Internet-facing</li>
            <li><strong>Protocol:</strong> HTTP (Port 80)</li>
            <li><strong>Health Checks:</strong> Custom endpoint /?health=check</li>
            <li><strong>Integration:</strong> Cognito authentication</li>
        </ul>
    </div>
    
    <h3>🔐 AWS Cognito</h3>
    <div class="service-info">
        <p><strong>Purpose:</strong> User authentication and authorization</p>
        <ul>
            <li><strong>MFA:</strong> Required (TOTP)</li>
            <li><strong>Password Policy:</strong> 12+ chars, mixed case, numbers, symbols</li>
            <li><strong>Account Recovery:</strong> Email-based</li>
            <li><strong>OAuth Flows:</strong> Authorization code grant</li>
        </ul>
    </div>
    
    <h3>🐳 Amazon ECS (Elastic Container Service)</h3>
    <div class="service-info">
        <p><strong>Purpose:</strong> Container orchestration for Streamlit application</p>
        <ul>
            <li><strong>Launch Type:</strong> Fargate</li>
            <li><strong>CPU:</strong> 512 units (0.5 vCPU)</li>
            <li><strong>Memory:</strong> 1024 MB (1 GB)</li>
            <li><strong>Network Mode:</strong> awsvpc</li>
        </ul>
    </div>
    
    <h3>🤖 Amazon Bedrock</h3>
    <div class="service-info">
        <p><strong>Purpose:</strong> AI/ML service providing Claude Sonnet 4 model</p>
        <ul>
            <li><strong>Model ID:</strong> us.anthropic.claude-sonnet-4-20250514-v1:0</li>
            <li><strong>API:</strong> Converse API</li>
            <li><strong>Access Method:</strong> VPC Endpoint (Private connectivity)</li>
        </ul>
    </div>
    
    <h2 id="security-implementation">4. 🔒 Security Implementation</h2>
    
    <h3>🛡️ Network Security</h3>
    <div class="security-feature">
        <h4>Network Segmentation:</h4>
        <ul>
            <li><strong>Public Subnets:</strong> ALB only (no compute resources)</li>
            <li><strong>Private Subnets:</strong> ECS tasks (no direct internet access)</li>
            <li><strong>Isolated Communication:</strong> VPC endpoints for AWS services</li>
        </ul>
    </div>
    
    <h3>🔑 Identity and Access Management (IAM)</h3>
    <div class="security-feature">
        <h4>ECS Task Role (Bedrock Access):</h4>
        <pre><code>{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:Converse",
        "bedrock:ListModels"
      ],
      "Resource": "*"
    }
  ]
}</code></pre>
    </div>
    
    <h2 id="execution-flow">5. 🔄 Execution Flow</h2>
    
    <h3>👤 User Request Flow</h3>
    <div class="flow-step">1. User → ALB (HTTP Request)</div>
    <div class="arrow">↓</div>
    <div class="flow-step">2. ALB → Cognito (Authentication Check)</div>
    <div class="arrow">↓</div>
    <div class="flow-step">3. Cognito → User (Login Page)</div>
    <div class="arrow">↓</div>
    <div class="flow-step">4. User → Cognito (Credentials + MFA)</div>
    <div class="arrow">↓</div>
    <div class="flow-step">5. Cognito → ALB (JWT Token)</div>
    <div class="arrow">↓</div>
    <div class="flow-step">6. ALB → ECS (Authenticated Request)</div>
    <div class="arrow">↓</div>
    <div class="flow-step">7. ECS → VPC Endpoint → Bedrock</div>
    <div class="arrow">↓</div>
    <div class="flow-step">8. Response back to User</div>
    
    <h2 id="deployment-pipeline">6. 🚀 Deployment Pipeline</h2>
    <div class="service-info">
        <h3>GitHub Actions Workflow</h3>
        <p><strong>Trigger Events:</strong></p>
        <ul>
            <li>Push to main/master branch</li>
            <li>Pull request to main/master branch</li>
        </ul>
        
        <p><strong>Pipeline Stages:</strong></p>
        <ol>
            <li>Checkout Code</li>
            <li>Configure AWS Credentials</li>
            <li>Setup Terraform</li>
            <li>Terraform Operations (init, plan, apply)</li>
            <li>Docker Operations (build, tag, push)</li>
            <li>ECS Deployment (update service)</li>
            <li>Output Results</li>
        </ol>
    </div>
    
    <h2 id="cost-analysis">7. 💰 Cost Analysis</h2>
    <div class="service-info">
        <h3>Monthly Cost Breakdown (Estimated)</h3>
        <table>
            <tr>
                <th>Service</th>
                <th>Configuration</th>
                <th>Monthly Cost</th>
            </tr>
            <tr>
                <td>ECS Fargate</td>
                <td>0.5 vCPU, 1GB RAM</td>
                <td>~$15</td>
            </tr>
            <tr>
                <td>NAT Gateway</td>
                <td>2 instances</td>
                <td>~$90</td>
            </tr>
            <tr>
                <td>Application Load Balancer</td>
                <td>Standard ALB</td>
                <td>~$20</td>
            </tr>
            <tr>
                <td>VPC Endpoints</td>
                <td>Interface endpoints</td>
                <td>~$22</td>
            </tr>
            <tr>
                <td>Bedrock Claude Sonnet 4</td>
                <td>Pay-per-use</td>
                <td>Variable</td>
            </tr>
            <tr>
                <td><strong>Total (excluding Bedrock)</strong></td>
                <td></td>
                <td><strong>~$150-200</strong></td>
            </tr>
        </table>
    </div>
    
    <h2 id="troubleshooting">8. 🔍 Troubleshooting Guide</h2>
    
    <h3>Common Issues</h3>
    <div class="service-info">
        <h4>ECS Tasks Not Starting</h4>
        <pre><code># Check service events
aws ecs describe-services --cluster bedrock-ecs-cluster --services bedrock-chatbot-service

# View task logs
aws logs tail /aws/ecs/bedrock-chatbot --follow</code></pre>
        
        <h4>Authentication Issues</h4>
        <pre><code># Verify Cognito configuration
aws cognito-idp describe-user-pool --user-pool-id &lt;pool-id&gt;

# Check user status
aws cognito-idp admin-get-user --user-pool-id &lt;pool-id&gt; --username &lt;email&gt;</code></pre>
        
        <h4>Bedrock Access Issues</h4>
        <pre><code># Test Bedrock access
aws bedrock-runtime converse --model-id us.anthropic.claude-sonnet-4-20250514-v1:0 --messages '[{"role":"user","content":[{"text":"Hello"}]}]'</code></pre>
    </div>
    
    <hr>
    <footer style="text-align: center; margin-top: 50px; color: #666;">
        <p><strong>Document Version:</strong> 1.0 | <strong>Last Updated:</strong> """ + datetime.now().strftime("%B %d, %Y") + """</p>
        <p><strong>Author:</strong> AWS Solutions Architecture Team</p>
    </footer>
</body>
</html>
    """
    
    # Create docs directory if it doesn't exist
    os.makedirs('../docs', exist_ok=True)
    
    # Write HTML file
    with open('../docs/Secure_Bedrock_Chatbot_Architecture.html', 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print("✅ HTML document generated: docs/Secure_Bedrock_Chatbot_Architecture.html")

def create_readme_summary():
    """Create a summary README for the documentation"""
    
    readme_content = f"""# 📄 Architecture Documentation

This directory contains comprehensive documentation for the Secure Bedrock Chatbot solution.

## 📋 Available Documents

### 1. Complete Architecture Document
- **File**: `ARCHITECTURE_DOCUMENT.md`
- **Format**: Markdown (source)
- **Content**: Complete technical documentation with all service details

### 2. HTML Documentation
- **File**: `docs/Secure_Bedrock_Chatbot_Architecture.html`
- **Format**: HTML (web-viewable)
- **Content**: Formatted version with styling and navigation

## 🔧 Generating Additional Formats

### Word Document (.docx)
```bash
# Install pandoc (if not already installed)
sudo apt-get install pandoc  # Linux
brew install pandoc          # macOS

# Generate Word document
pandoc ARCHITECTURE_DOCUMENT.md -o docs/Architecture.docx --toc
```

### PDF Document
```bash
# Generate PDF (requires pandoc and LaTeX)
pandoc ARCHITECTURE_DOCUMENT.md -o docs/Architecture.pdf --toc
```

## 📖 Document Sections

1. **Executive Summary** - High-level overview and key features
2. **Architecture Overview** - Visual architecture diagram
3. **Service Components** - Detailed service descriptions
4. **Security Implementation** - Security controls and configurations
5. **Network Architecture** - VPC design and routing
6. **Execution Flow** - Step-by-step process flows
7. **Deployment Pipeline** - CI/CD implementation
8. **Monitoring & Logging** - Observability setup
9. **Cost Analysis** - Pricing breakdown and optimization
10. **Troubleshooting Guide** - Common issues and solutions

## 🎯 Quick Access

- **View Online**: Open `docs/Secure_Bedrock_Chatbot_Architecture.html` in your browser
- **Edit Source**: Modify `ARCHITECTURE_DOCUMENT.md`
- **Generate Formats**: Run `scripts/generate-word-doc.sh`

## 📞 Support

For questions about the documentation:
1. Check the troubleshooting section
2. Review the execution flow diagrams
3. Consult the service component details

---
*Last Updated: {datetime.now().strftime("%B %d, %Y")}*
"""
    
    with open('../docs/README.md', 'w', encoding='utf-8') as f:
        f.write(readme_content)
    
    print("✅ Documentation README generated: docs/README.md")

if __name__ == "__main__":
    print("🔄 Generating comprehensive documentation...")
    
    try:
        create_html_document()
        create_readme_summary()
        
        print("\n🎉 Documentation generation complete!")
        print("\n📄 Generated files:")
        print("   - docs/Secure_Bedrock_Chatbot_Architecture.html")
        print("   - docs/README.md")
        print("\n💡 To generate Word/PDF formats:")
        print("   - Install pandoc: sudo apt-get install pandoc")
        print("   - Run: ./scripts/generate-word-doc.sh")
        
    except Exception as e:
        print(f"❌ Error generating documentation: {e}")
        sys.exit(1)
