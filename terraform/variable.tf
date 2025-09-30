variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "image_tag" {
  description = "The image tag for the Docker container."
  type        = string
  default     = "latest"
}

variable "domain_name" {
  description = "The domain name for SSL certificate"
  type        = string
  default     = "example.com"
}

