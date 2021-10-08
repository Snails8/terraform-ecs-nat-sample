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

# Subnet
resource "aws_subnet" "ec2" {
  cidr_block        = "10.0.100.0/24"
  availability_zone = "ap-northeast-1a"
  vpc_id            = aws_vpc.main.id

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-ec2"
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

# RouteTableAssociation(EC2) EC2 subnet と関連付け
resource "aws_route_table_association" "ec2" {
  subnet_id = aws_subnet.ec2.id
  route_table_id = aws_route_table.main.id
}
# ==================================================================
# EC2作成時に使うVPCのidとSubnet_idを ./main.tf に渡してやる
#
# ==================================================================

output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_subnet_id" {
  value = aws_subnet.ec2.id
}