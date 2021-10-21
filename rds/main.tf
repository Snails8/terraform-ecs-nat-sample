# RDS 作成に必要なサービスの用意
# RDS インスタンス, DB用のセキュリティグループ, DB用のprivate subnet group
locals {
  name = "${var.app_name}-pgsql"
}

# =====================================================
# DB用のセキュリティグループ作成
#
# グループ名,説明, VPC選択, インバウンドルール
# =====================================================

resource "aws_security_group" "main" {
  name        = local.name
  description = local.name

  vpc_id = var.vpc_id

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.name
  }
}

# inbound (cidrs は環境に応じて変更してください。)
resource "aws_security_group_rule" "pgsql" {
  security_group_id = aws_security_group.main.id

  type = "ingress"

  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
}

# =====================================================
# DB用のprivate-subnet-group
#
# グループ名,説明, VPC選択, subnet選択
# =====================================================

resource "aws_db_subnet_group" "main" {
  name        = local.name
  description = local.name
  subnet_ids  = var.private_subnet_ids
}

# =====================================================
# RDS インスタンス作成
#
# エンジン選択, version 選択, クラスの選択, タイプの選択, 割り当て, 自動スケーリングの有無, マルチAZ設定,
# VPC, subnet group, security group, public アクセス(default =false), 識別子名, ユーザー名, password, AZ 指定
#
# 自動スケーリング等の設定がしたい場合、公式を読んでください https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#example-usage
# 注意: tfstateファイルには生のパスワードが記載されるので。取り扱いには注意
# =====================================================
resource "aws_db_instance" "main" {
  identifier = local.name

  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  engine            = "postgres"
  engine_version    = "11.12"
  instance_class    = "db.t2.micro"
  storage_type      = "gp2"
  allocated_storage = 20
  multi_az          = false

  port = 5432

  name = var.app_name
  username = var.master_username
  password = var.master_password

  final_snapshot_identifier = local.name  # DBスナップショットの名前
  skip_final_snapshot = false  # default はfalse
}