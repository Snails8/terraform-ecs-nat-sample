variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

# ecs > network_configuration で 使用
variable "public_subnet_ids" {
  type = list(string)
}

# ELB の設定 ecs >load_balancer >aws_lb_listener_rule で使用
variable "https_listener_arn" {
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