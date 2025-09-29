provider "aws" {
  region  = var.aws_region
  profile = "bedrockuser"
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
