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