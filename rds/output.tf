output "endpoint" {
  value = aws_db_instance.main.endpoint
}

# 作成後のoutput及びgithub action の環境変数で使用
output "db_security_group" {
  value = aws_security_group.main.id
}