variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "domain" {
  type = string
}

variable "zone" {
  type = string
}

# listener rule httpsで使用
variable "acm_id" {
  type = string
}

variable "alb_sg" {
  description = "HTTP access security group"
  type        = string
}

# 開発環境ではホストゾーンを指定するドメインがそもそも存在しないのでresourceで作成している(本来はdata が望ましい。その場合参照方法に注意)
data "aws_route53_zone" "main" {
  name         = var.zone
  private_zone = false
}