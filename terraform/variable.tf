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

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

}

variable "image_tag" {
  description = "The image tag for the Docker container."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port on which the container will listen."
  type        = number
  default     = 8501
}

