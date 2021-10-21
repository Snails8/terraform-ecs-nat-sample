data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  app_name = var.app_name
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
}

# コンテナ定義を呼び出す
data "template_file" "container_definitions" {
  template = file("./ecs/app/container_definitions.json")

  vars = {
    tag = "latest"
    name = var.app_name
    account_id = local.account_id
    region = local.region

    loki_user = var.loki_user
    loli_pass = var.loki_pass
  }
}
# =========================================================
# CloudWatch Logsの出力先（Log Group）
#
# Logの設定自体はjson。あくまでwebとappの出力先を指定
# =========================================================
resource "aws_cloudwatch_log_group" "main" {
  name = "/${local.app_name}/ecs"
  retention_in_days = 7
}

# =========================================================
# Task Definition
#
# =========================================================
resource "aws_ecs_task_definition" "main" {
  family = var.app_name

  # データプレーンの選択
  requires_compatibilities = ["FARGATE"]
  # ECSタスクが使用可能なリソースの上限
  # タスク内のコンテナはこの上限内に使用するリソースを収める必要があり、メモリが上限に達した場合OOM Killer にタスクがキルされる
  cpu = 256
  memory = 512

  # ECSタスクのネットワークドライバ  :Fargateを使用する場合は"awsvpc"
  network_mode = "awsvpc"

  # 起動するコンテナの定義 (nginx, app)
  container_definitions = data.template_file.container_definitions.rendered

  volume {
    name = "app-storage"
  }

  # 実行するuser の設定
  task_role_arn      = var.iam_role_task_execution_arn
  execution_role_arn = var.iam_role_task_execution_arn
}

# ========================================================
# ECS 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# ========================================================
resource "aws_ecs_service" "main" {
  # 依存関係の記述 : aws_lb_listener_rule.main" リソースの作成が完了するのを待ってから当該リソースの作成を開始
  depends_on = [aws_lb_listener_rule.main]

  # clusterの指定
  cluster = var.cluster_name
  name = var.app_name

  launch_type = "FARGATE"
  platform_version = "1.4.0"

  # task_definition = aws_ecs_task_definition.main.arn
  # GitHubActionsと整合性を取りたい場合は下記のようにrevisionを指定しなければよい
  task_definition = "arn:aws:ecs:ap-northeast-1:${local.account_id}:task-definition/${aws_ecs_task_definition.main.family}"

  network_configuration {
    subnets = var.public_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name = "nginx"
    container_port = 80
  }
}

# Security Group
resource "aws_security_group" "ecs" {
  name = "${var.app_name}-ecs"
  description = "${var.app_name}-ecs"

  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs"
  }
}

# Security Group Rule
resource "aws_security_group_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# ==========================================================
# ALB の設定
# ==========================================================
# ターゲットグループ: ヘルスチェック(死活監視)を行う
resource "aws_lb_target_group" "main" {
  name = var.app_name

  vpc_id = var.vpc_id

  # ALBからECSタスクのコンテナへトラフィックを振り分ける設定(ECS(nginx)へ流す)
  port = 80
  target_type = "ip"
  protocol = "HTTP"

  # コンテナへの死活監視設定
  health_check {
    port = 80
    path = "/"
  }
}

# リスナー: ロードバランサがリクエスト受けた際、どのターゲットグループへリクエストを受け渡すのかの設定
resource "aws_lb_listener_rule" "main" {
  # リスナー(アクセス可能にするALBの設定)の指定
  listener_arn = var.https_listener_arn

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
