#!/bin/bash

# Simplified User Management for Bedrock Chatbot
# Since we're using simple password authentication, this script provides info

set -e

echo "🔐 Bedrock Chatbot - User Management"
echo "===================================="
echo ""

case "$1" in
    "info")
        echo "📋 Authentication Information:"
        echo ""
        echo "🔑 Login Method: Simple Password Authentication"
        echo "🔒 Default Password: SecurePass123!"
        echo "🌐 Access URL: $(terraform -chdir=terraform output -raw application_url 2>/dev/null || echo 'Run terraform first')"
        echo ""
        echo "📝 To change the password:"
        echo "   1. Edit app.py"
        echo "   2. Change the password in check_password() function"
        echo "   3. Rebuild and redeploy the container"
        echo ""
        ;;
    "url")
        echo "🌐 Application URL:"
        terraform -chdir=terraform output -raw application_url 2>/dev/null || echo "❌ Run terraform apply first"
        ;;
    "password")
        echo "🔑 Current Password: SecurePass123!"
        echo ""
        echo "⚠️  To change password:"
        echo "   1. Edit app.py line with 'SecurePass123!'"
        echo "   2. Rebuild container: docker build -t bedrock-chatbot ."
        echo "   3. Push to ECR and update ECS service"
        ;;
    *)
        echo "Usage: $0 {info|url|password}"
        echo ""
        echo "Commands:"
        echo "  info     - Show authentication information"
        echo "  url      - Display application URL"
        echo "  password - Show password information"
        echo ""
        echo "Examples:"
        echo "  $0 info"
        echo "  $0 url"
        echo "  $0 password"
        exit 1
        ;;
esac
