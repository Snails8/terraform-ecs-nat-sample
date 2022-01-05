resource "aws_security_group" "redis_ecs" {
  name        = "${var.app_name}-redis_ecs"
  description = "${var.app_name}-redis_ecs"
  vpc_id = var.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
  }

  # aws_security_group_rule
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
  }

  tags = {
    Name = "${var.app_name}-redis_ecs"
  }
}