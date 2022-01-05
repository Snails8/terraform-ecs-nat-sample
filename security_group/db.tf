resource "aws_security_group" "db" {
  name        = "${var.app_name}-db"
  description = "${var.app_name}-db"
  vpc_id      = var.vpc_id

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-db"
  }
}

# inbound (cidrs は環境に応じて変更してください。)
resource "aws_security_group_rule" "pgsql" {
  security_group_id = aws_security_group.main.id

  type = "ingress"

  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
}