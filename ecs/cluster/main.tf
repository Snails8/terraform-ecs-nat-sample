# ========================================================
# ECS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# ========================================================
variable "app_name" {
  type = string
}

resource "aws_ecs_cluster" "main" {
  name = var.app_name
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}