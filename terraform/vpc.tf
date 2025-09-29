data "aws_availability_zones" "available" {}

resource "aws_vpc" "bedrock_main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "bedrock_main_vpc"
  }

}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.bedrock_main.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }

}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.bedrock_main.id
  tags = {
    Name = "bedrock_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.bedrock_main.id

  tags = {
    Name = "bedrock_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id

}