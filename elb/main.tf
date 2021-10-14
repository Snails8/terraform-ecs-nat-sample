# ===========================================================================
# ELB の設定 AWS Elastic Load Balancing
#
# 受信したトラフィックを複数のアベイラビリティーゾーンの複数のターゲット (EC2 インスタンス、コンテナ、IP アドレスなど) に自動的に分散
# 登録されているターゲットの状態をモニタリングし、正常なターゲットにのみトラフィックをルーティング
# 使用すると負荷分散による障害耐性がつく

# 、Application Load Balancer、Network Load Balancer、Gateway Load Balancer、Classic Load Balancer といったロードバランサーをサポート
# ===========================================================================

variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

# ========================================================================
# LB
# https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/introduction.html

# ALB : Application Load Balancer
# 公式推奨: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
# ========================================================================

# TODO::ALB の接続設定をprivateに変更
resource "aws_lb" "main" {
  load_balancer_type = "application"
  name               = var.app_name

  security_groups = [aws_security_group.main.id]
  # 対象のsubnet
  subnets = var.public_subnet_ids
}

# Security Group
resource "aws_security_group" "main" {
  name        = "${var.app_name}-alb"
  description = "${var.app_name}-alb"
  vpc_id      = var.vpc_id

  # アウトバウンド 設定
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# SGR HTTP
resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.main.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# 接続リクエストのリスナー設定(HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn

  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

# ロードバランサーがリクエストを受け渡すルール
output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}