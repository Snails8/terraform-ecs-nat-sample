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