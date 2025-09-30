provider "aws" {
  region  = var.aws_region
  #profile = "bedrockuser1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2"
}


terraform {
  backend "s3" {
    bucket         = "my-bedrockchatbot-tf-state"   #  S3 bucket name
    key            = "terraform/state.tfstate"       # Path inside the bucket
    region         = "eu-west-2"                     #  AWS region
    #profile        = "bedrockuser1"
    #dynamodb_table = "terraform-locks"               # DynamoDB table for state locking
    #encrypt        = true
  }
}