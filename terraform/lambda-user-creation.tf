# Optional: Lambda function to create default user
# Uncomment this file if you want Lambda-based user creation

# resource "aws_lambda_function" "create_default_user" {
#   filename         = "create_user.zip"
#   function_name    = "bedrock-create-default-user"
#   role            = aws_iam_role.lambda_role.arn
#   handler         = "index.handler"
#   runtime         = "python3.9"
#   timeout         = 30

#   depends_on = [data.archive_file.lambda_zip]
# }

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   output_path = "create_user.zip"
#   source {
#     content = <<EOF
# import boto3
# import json

# def handler(event, context):
#     cognito = boto3.client('cognito-idp')
#     user_pool_id = '${aws_cognito_user_pool.bedrock_user_pool.id}'
    
#     try:
#         # Check if user exists
#         cognito.admin_get_user(UserPoolId=user_pool_id, Username='admin')
#         return {'statusCode': 200, 'body': 'User already exists'}
#     except:
#         # Create user
#         cognito.admin_create_user(
#             UserPoolId=user_pool_id,
#             Username='admin',
#             UserAttributes=[
#                 {'Name': 'email', 'Value': 'admin@example.com'},
#                 {'Name': 'email_verified', 'Value': 'true'}
#             ],
#             MessageAction='SUPPRESS'
#         )
        
#         # Set password
#         cognito.admin_set_user_password(
#             UserPoolId=user_pool_id,
#             Username='admin',
#             Password='Admin123!',
#             Permanent=True
#         )
        
#         # Confirm user
#         cognito.admin_confirm_sign_up(
#             UserPoolId=user_pool_id,
#             Username='admin'
#         )
        
#         return {'statusCode': 200, 'body': 'User created successfully'}
# EOF
#     filename = "index.py"
#   }
# }

# resource "aws_iam_role" "lambda_role" {
#   name = "bedrock-lambda-user-creation-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "lambda_cognito_policy" {
#   name = "lambda-cognito-policy"
#   role = aws_iam_role.lambda_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "cognito-idp:AdminCreateUser",
#           "cognito-idp:AdminSetUserPassword",
#           "cognito-idp:AdminConfirmSignUp",
#           "cognito-idp:AdminGetUser"
#         ]
#         Resource = aws_cognito_user_pool.bedrock_user_pool.arn
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# # Trigger Lambda after Cognito User Pool is created
# resource "aws_lambda_invocation" "create_user_trigger" {
#   function_name = aws_lambda_function.create_default_user.function_name
#   input = jsonencode({})
#   depends_on = [aws_cognito_user_pool.bedrock_user_pool]
# }
