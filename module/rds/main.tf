# =====================================================
# DB用のprivate-subnet-group
# =====================================================
resource "aws_db_subnet_group" "main" {
  name        = lower(replace(var.app_name, "-", "_"))
  description = local.name
  subnet_ids  = var.private_subnet_ids
}

# =====================================================
# RDS インスタンス作成
#
# 自動スケーリング等の設定がしたい場合、公式を読んでください https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#example-usage
# 注意: tfstateファイルには生のパスワードが記載されるので。取り扱いには注意
# =====================================================
resource "aws_db_instance" "main" {
  identifier             = var.database_name
  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  engine            = "postgres"
  engine_version    = "11.12"
  instance_class    = "db.t2.micro"
  storage_type      = "gp2"
  allocated_storage = 20
  multi_az          = false

  port = 5432

  name = var.database_name
  username = var.master_username
  password = var.master_password

  final_snapshot_identifier = var.database_name  # DBスナップショットの名前
  skip_final_snapshot = false  # default はfalse
}