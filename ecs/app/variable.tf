variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

# ECSのsg
variable "sg_list" {
  description = "ECS security group.HTTP/HTTP security group is expected"
  type        = list(string)
}

# ecs  で 使用
variable "private_subnet_ids" {
  type = list(string)
}

# ELB の設定 ecs >load_balancer >aws_lb_listener_rule で使用
variable "https_listener_arn" {
  type = string
}

# container definition で使用
variable "app_key" {
  type = string
}

# cluster
variable "cluster_name" {
  type = string
}

#  Log
variable "loki_user" {
  type = string
}

variable "loki_pass" {
  type = string
}

# タスクに関連付けるIAM
variable "iam_role_task_execution_arn" {
  type = string
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  app_name   = var.app_name
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# コンテナ定義を呼び出す
data "template_file" "container_definitions" {
  template = file("./ecs/app/container_definitions.json")

  vars = {
    tag        = "latest"
    name       = var.app_name
    account_id = local.account_id
    region     = local.region
    app_key    = var.app_key
    loki_user  = var.loki_user
    loki_pass  = var.loki_pass
  }
}