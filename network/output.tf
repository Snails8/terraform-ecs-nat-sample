# ==================================================================
#  ./main.tf にOutput
#
# ==================================================================
# 各種要素で使用
output "vpc_id" {
  value = aws_vpc.main.id
}

# EC2 で使用
output "ec2_subnet_id" {
  value = aws_subnet.ec2.id
}

# RDS で使用
output "private_subnet_ids" {
  value = aws_subnet.privates.*.id
}

# ECS で使用
output "public_subnet_ids" {
  value = aws_subnet.publics.*.id
}