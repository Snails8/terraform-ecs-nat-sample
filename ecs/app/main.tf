# ecs
variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

# ecs->network_configuration で 使用
variable "public_subnet_ids" {
  type = list(string)
}

# ecs->load_balancer->aws_lb_listener_rule で使用
variable "http_listener_arn" {
  type = string
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
}

# =========================================================
# Task Definition
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
# =========================================================

# コンテナ定義を呼び出す
data "template_file" "container_definitions" {
  template = file("./ecs/app/container_definitions.json")

  vars = {
    tag = "latest"
    name = var.app_name
    account_id = local.account_id
    region = local.region
  }
}

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

#  task_role_arn      = var.iam_role_task_execution_arn
#  execution_role_arn = var.iam_role_task_execution_arn
}

# ========================================================
# ECS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# ========================================================
resource "aws_ecs_cluster" "main" {
  name = "handson"
}

resource "aws_ecs_service" "main" {
  name = var.app_name

  launch_type = "FARGATE"
  platform_version = "1.4.0"

  cluster = "sample"

  task_definition = aws_ecs_task_definition.main.arn

  # GitHubActionsと整合性を取りたい場合は下記のようにrevisionを指定しなければよい
  # task_definition = "arn:aws:ecs:ap-northeast-1:${local.account_id}:task-definition/${aws_ecs_task_definition.main.family}"

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

resource "aws_lb_target_group" "main" {
  name = var.app_name

  vpc_id = var.vpc_id

  port = 80
  target_type = "ip"
  protocol = "HTTP"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.http_listener_arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
