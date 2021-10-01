# Network設定(VPC, Subnet, IGW, RouteTable  の設定)

#  親からAZとapp_nameを受け取る
variable "app_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

# VPCのCIDR設定 (default のIPアドレスを設定している)
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# aws_vpc に入れないといけないもんもがterraform に書かれている。IPとタグ
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.app_name
  }
}


# Subnet :親(VPC)から公開領域を用意
variable "public_subnet_cidrs" {
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

# VPCからアクセス。そのネットワーク内のみアクセス可能なもの
variable "private_subnet_cidrs" {
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

# Subnets(Public)
resource "aws_subnet" "publics" {
  count = length(var.public_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  availability_zone = var.azs[count.index]
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = {
    Name = "${var.app_name}-public-${count.index}"
  }
}

# Subnet(Private)
resource "aws_subnet" "privates" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  availability_zone = var.azs[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.app_name}-private-${count.index}"
  }
}


# IGW (インターネットゲートウェイ)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}


# RouteTable
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}

# Route
resource "aws_route" "main" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.main.id
  gateway_id = aws_internet_gateway.main.id
}

# RouteTableAssociation(Public)
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id = element(aws_subnet.publics.*.id, count.index)
  route_table_id = aws_route_table.main.id
}