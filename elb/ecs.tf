# ==========================================================
# ECS ALB  target group の設定
# ==========================================================
# ターゲットグループ: ヘルスチェック(死活監視)を行う
resource "aws_lb_target_group" "main" {
  name = var.app_name
  vpc_id = var.vpc_id

  # ALBからECSタスクのコンテナへトラフィックを振り分ける設定(ECS(nginx)へ流す)
  target_type = "ip"
  port = 80
  deregistration_delay = 300
  protocol = "HTTP"

  # コンテナへの死活監視設定
  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = 80
    protocol            = "HTTP"
  }
}

# リスナー: ロードバランサがリクエスト受けた際、どのターゲットグループへリクエストを受け渡すのかの設定
resource "aws_lb_listener_rule" "main" {
  # リスナー(アクセス可能にするALBの設定)の指定
  listener_arn = aws_lb_listener.https.arn

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}