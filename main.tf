# provider の設定 ( provider は aws 専用ではなくGCPとかも使える)
provider "aws" {
  region = "ap-northeast-1"
}

variable "app_name" {
  type = string
  default = "sample"
}

# AZ の設定(冗長化のため配列でlist化してある)
variable "azs" {
  type = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

# module( VPC, subnet(pub, pri), IGW, RouteTable, Route, RouteTableAssociation )
module "network" {
  source = "./network"
  app_name = var.app_name
  azs = var.azs
}

# EC2 (vpc_id, subnet_id が必要)
module "ec2" {
  source = "./ec2"
  app_name = var.app_name
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.ec2_subnet_id
}

# ========================================================
# ECS 作成
#
#
# ========================================================
module "ecs" {
  source = "./ecs/app"
  app_name = var.app_name
  vpc_id   = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  # elb の設定
  http_listener_arn  = module.elb.http_listener_arn
}

# cluster 作成
module "ecs_cluster" {
  source = "./ecs/cluster"
  app_name = var.app_name
}

# ELB の設定
module "elb" {
  source = "./elb"
  app_name = var.app_name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

# ========================================================
# RDS 作成
#
# [subnetGroup, securityGroup, RDS instance(postgreSQL)]
# ========================================================

variable "DB_NAME" {
  type = string
}

variable "DB_MASTER_NAME" {
  type = string
}

variable "DB_MASTER_PASS" {
  type = string
}

# RDS (PostgreSQL)
module "rds" {
  source = "./rds"

  app_name = var.app_name
  vpc_id   = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  database_name = var.DB_NAME
  master_username   = var.DB_MASTER_NAME
  master_password   = var.DB_MASTER_PASS
}