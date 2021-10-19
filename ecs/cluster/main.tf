# EC@
variable "app_name" {
  type = string
}

# ========================================================
# ECS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
# ========================================================
resource "aws_ecs_cluster" "main" {
  name = var.app_name
  
  # Container Insightsの使用(Log)
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECSに紐付けて使用
output "cluster_name" {
  value = aws_ecs_cluster.main.name
}