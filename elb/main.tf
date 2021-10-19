# ===========================================================================
# ELB の設定 AWS Elastic Load Balancing
#
# 受信したトラフィックを複数のアベイラビリティーゾーンの複数のターゲット (EC2 インスタンス、コンテナ、IP アドレスなど) に自動的に分散
# 登録されているターゲットの状態をモニタリングし、正常なターゲットにのみトラフィックをルーティング
# 使用すると負荷分散による障害耐性がつく

# Application Load Balancer、Network Load Balancer、Gateway Load Balancer、Classic Load Balancer といったロードバランサーをサポート
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
# ALB 作成
# https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/introduction.html

# ALB : Application Load Balancer
# 公式推奨: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
# ========================================================================

# TODO::ALB の接続設定をprivateに変更
resource "aws_lb" "main" {
  load_balancer_type = "application"
  name               = var.app_name

  security_groups = [aws_security_group.main.id]
  subnets = var.public_subnet_ids
}

# Security Group
resource "aws_security_group" "main" {
  name        = "${var.app_name}-alb"
  description = "${var.app_name}-alb"
  vpc_id      = var.vpc_id

  # セキュリティグループ内のリソースからインターネットへのアクセスを許可する
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

  # セキュリティグループ内のリソースへインターネットからのアクセスを許可する
  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# ============================================================
# 接続リクエストのLBの設定(リスナーの追加) (HTTP)
# これがないとALBにアクセスできない 
# 設定するとDNSにアクセスした際にALBがhttpを受け付けるように
# ============================================================
resource "aws_lb_listener" "http" {
  # HTTPでのアクセスを受け付ける
  port = 80
  protocol = "HTTP"

  # ALBのarnを指定( arn: Amazon Resource Names の略で、その名の通りリソースを特定するための一意な名前(id))
  load_balancer_arn = aws_lb.main.arn

  # "ok" という固定レスポンスを設定する
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