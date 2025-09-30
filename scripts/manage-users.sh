#!/bin/bash

# User Management Script for Bedrock Chatbot
set -e

# Get User Pool ID from Terraform output
USER_POOL_ID=$(terraform -chdir=terraform output -raw cognito_user_pool_id 2>/dev/null || echo "")

if [ -z "$USER_POOL_ID" ]; then
    echo "Error: Could not get User Pool ID. Make sure Terraform is deployed."
    exit 1
fi

echo "User Pool ID: $USER_POOL_ID"

# Function to create user
create_user() {
    local email=$1
    local temp_password=$2
    local permanent_password=$3
    
    echo "Creating user: $email"
    
    # Create user
    aws cognito-idp admin-create-user \
        --user-pool-id "$USER_POOL_ID" \
        --username "$email" \
        --user-attributes Name=email,Value="$email" \
        --temporary-password "$temp_password" \
        --message-action SUPPRESS \
        --region us-west-2
    
    # Set permanent password
    aws cognito-idp admin-set-user-password \
        --user-pool-id "$USER_POOL_ID" \
        --username "$email" \
        --password "$permanent_password" \
        --permanent \
        --region us-west-2
    
    echo "User $email created successfully!"
}

# Function to delete user
delete_user() {
    local email=$1
    
    echo "Deleting user: $email"
    aws cognito-idp admin-delete-user \
        --user-pool-id "$USER_POOL_ID" \
        --username "$email" \
        --region us-west-2
    
    echo "User $email deleted successfully!"
}

# Function to list users
list_users() {
    echo "Listing all users:"
    aws cognito-idp list-users \
        --user-pool-id "$USER_POOL_ID" \
        --region us-west-2 \
        --query 'Users[].{Username:Username,Email:Attributes[?Name==`email`].Value|[0],Status:UserStatus}' \
        --output table
}

# Main script logic
case "$1" in
    "create")
        if [ $# -ne 4 ]; then
            echo "Usage: $0 create <email> <temp_password> <permanent_password>"
            echo "Example: $0 create user@example.com TempPass123! SecurePass123!"
            exit 1
        fi
        create_user "$2" "$3" "$4"
        ;;
    "delete")
        if [ $# -ne 2 ]; then
            echo "Usage: $0 delete <email>"
            exit 1
        fi
        delete_user "$2"
        ;;
    "list")
        list_users
        ;;
    *)
        echo "Usage: $0 {create|delete|list}"
        echo ""
        echo "Commands:"
        echo "  create <email> <temp_pass> <permanent_pass> - Create a new user"
        echo "  delete <email>                              - Delete a user"
        echo "  list                                        - List all users"
        echo ""
        echo "Examples:"
        echo "  $0 create admin@company.com TempPass123! SecurePass123!"
        echo "  $0 list"
        echo "  $0 delete admin@company.com"
        exit 1
        ;;
esac
