// VPC の設定
// provider はaws 専用ではなくGCPとかも使える
provider "aws" {
  region = "ap-northeast-1"
}

variable "app_name" {
  default = "suzuki-test-app"
}  
// variable 変数
// default のIPアドレスを設定している
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

// aws_vpc に入れないといけないもんもがterraform に書かれている。IPとタグ
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.app_name
  }
}
