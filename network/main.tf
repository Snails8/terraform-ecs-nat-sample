# Network設定(VPC, Subnet, IGW, RouteTable  の設定)

#  親からAZとapp_nameを受け取る
variable "app_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

# ==============================================================
# VPC
# cidr,tag_name
# ==============================================================

# VPCのCIDR設定 (default のIPアドレスを設定している)
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# VPC 作成(最低限: sidr とtag )
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true # DNS解決を有効化
  enable_dns_support   = true  # DNSホスト名を有効化

  tags = {
    Name = var.app_name
  }
}

#================================================================
# Subnet
# VPC選択, name, AZ, cidr
#================================================================

variable "public_subnet_cidrs" {
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

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

# ==================================================================
# IGW (インターネットゲートウェイ)
# tag_name, vpc選択(Attached)
# ==================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}

# ==================================================================
# RouteTable
# VPC作成時に自動生成される項目
# ==================================================================
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.app_name
  }
}

# Route  :RouteTable に IGW へのルートを指定してあげる
resource "aws_route" "main" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.main.id
  gateway_id = aws_internet_gateway.main.id
}

# RouteTableAssociation(Public)  :RouteTable にsubnet を関連付け => インターネット通信可能に
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id = element(aws_subnet.publics.*.id, count.index)
  route_table_id = aws_route_table.main.id
}