variable "APP_NAME" {
  type = string
}

# AZ の設定(冗長化のため配列でlist化してある)
variable "azs" {
  type = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# ELB で使用 https化に使う
variable "DOMAIN" {
  type = string
}

# acm で使用 (TLS証明書)
variable "ZONE" {
  type = string
}

variable "APP_KEY" {
  type = string
}

variable "LOKI_USER" {
  type = string
}

variable "LOKI_PASS" {
  type = string
}

# RDS で使用
variable "DB_NAME" {
  type = string
}

variable "DB_MASTER_NAME" {
  type = string
}

variable "DB_MASTER_PASS" {
  type = string
}

# 以下固定化し共有するときに使用
#variable "app_name" {
#  type = string
#  default = "sample"
#}
#variable "domain" {
#  type = string
#  default = "snails8.site"
#}
#
#variable "zone" {
#  type = string
#  default = "snails8.site"
#}