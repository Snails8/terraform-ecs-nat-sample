# ECSで使用
output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}

# redis で使用
output "redis_ecs_sg_id" {
  value = aws_security_group.redis_ecs.id
}

# ALB / ECSでも使用
output "alb_sg_id" {
  value = aws_security_group.main.id
}

# RDS で使用
output "db_sg_id" {
  value = aws_security_group.db.id
}

# ec2の設定で使用
output "ssh_sg_id" {
  value = aws_security_group.ssh.id
}