# ===============================================================================
# ECS のsg
# ===============================================================================
resource "aws_security_group" "ecs" {
  name = "${var.app_name}-ecs"
  description = "${var.app_name}-ecs"
  vpc_id = var.vpc_id

  # 入り口を定義しないとprivate構成では503になる
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # セキュリティグループ内のリソースからインターネットへのアクセス許可設定(docker-hubのpullに使用
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecsEndpoint"
  }
}

# Security Group Rule(ingress: インターネットからセキュリティグループ内のリソースへのアクセス許可設定)
resource "aws_security_group_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # 同一VPC内からのアクセスのみ許可
  cidr_blocks = ["0.0.0.0/16"]
}