variable "zone" {
  type = string
}

variable "domain" {
  type = string
}

data "aws_route53_zone" "main" {
  name         = var.zone
  private_zone = false
}