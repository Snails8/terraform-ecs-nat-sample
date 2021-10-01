# provider の設定 ( provider は aws 専用ではなくGCPとかも使える)
provider "aws" {
  region = "ap-northeast-1"
}

variable "app_name" {
  type = string
  default = "suzuki-test-app"
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