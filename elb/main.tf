# ===========================================================================
# ELB の設定 AWS Elastic Load Balancing
#
# 1. ALBの作成
# 1-1. httpとhttpsの通信を受け取れるように
# 2. 通信を行うためにALBのリスナー設定( http => httpsに流す )
# 3. ECSのnginxに流してやる(処理の依存関係上ココでは行わないのでoutput)

# ACM ECS と依存関係
# ===========================================================================

# 開発環境ではホストゾーンを指定するドメインがそもそも存在しないのでresourceで作成している(本来はdata が望ましい。その場合参照方法に注意)
resource "aws_route53_zone" "main" {
  name         = var.zone
  # private_zone = false  
}
# data "aws_route53_zone" "main" {
  # name         = var.zone
  # private_zone = false  
# }

# ========================================================================
# ALB 作成 (+ subnets , security Group 紐付け)
# https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/introduction.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
# ========================================================================

# TODO::ALB の接続設定をprivateに変更
resource "aws_lb" "main" {
  load_balancer_type = "application"
  name               = var.app_name

  security_groups = [aws_security_group.main.id]
  subnets         = var.public_subnet_ids
}

# Security Group
resource "aws_security_group" "main" {
  name        = "${var.app_name}-alb"
  description = "${var.app_name}-alb"
  vpc_id      = var.vpc_id

  # セキュリティグループ内のリソースからインターネットへのアクセスを許可する
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

# http通信を受け取れるように
resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.main.id

  # セキュリティグループ内のリソースへインターネットからのアクセスを許可する
  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# ALB用セキュリティグループへhttpsも受け付けるようルールを追加する
resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.main.id

  type = "ingress"

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

# ============================================================
# 接続リクエストのLBの設定(リスナーの追加) (HTTP)
# 
# これがないとALBにアクセスできない 
# 設定するとDNSにアクセスした際にALBがhttpを受け付けるように
# ============================================================
resource "aws_lb_listener" "http" {
  # HTTPでのアクセスを受け付ける
  port = 80
  protocol = "HTTP"

  # ALBのarnを指定( arn: Amazon Resource Names の略で、その名の通りリソースを特定するための一意な名前(id))
  load_balancer_arn = aws_lb.main.arn
  
  # httpで来たリクエストをhttpsへリダイレクトさせる
  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
# https 
resource "aws_lb_listener" "https" {
  port     = 443
  protocol = "HTTPS"

  # TSL証明書等を受け取る(処理はacm)
  certificate_arn   = var.acm_id
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

# =============================================================
# https対応: ドメインと紐付け
# =============================================================
# Route53 A record  ALBとドメインの紐付け用レコード
resource "aws_route53_record" "main" {
  type = "A"

  name    = var.domain
  zone_id = aws_route53_zone.main.id
  # zone_id = data.aws_route53_zone.main.id

  # = は付けない
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}