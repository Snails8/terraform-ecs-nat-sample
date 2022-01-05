variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_sg_id" {
  type        = string
  description = "RDB security group"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "database_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}

locals {
  name = "${var.app_name}-pgsql"
}