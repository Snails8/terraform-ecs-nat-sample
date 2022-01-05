# ========================================================
# SecurityGroup
# name, description, vpc_id, Rule, egress,
# terraform での作成の場合、GUIでは自動で設定してくれるアウトバウンドを設定する必要がある(GUIの default は有効)
# outbound 機器から外部に出力されるパケットをエグレス 上り
# -1 にすればterraform側で勝手に オールにする https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#egress
# ========================================================
resource "aws_security_group" "ssh" {
  vpc_id = var.vpc_id

  name        = "${var.app_name}-ec2"
  description = "${var.app_name}-ec2"

  # アウトバウンド 設定
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ec2"
  }
}

# SecurityGroupRule SSH
resource "aws_security_group_rule" "ingress_ssh" {
  security_group_id = aws_security_group.ssh.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# SecurityGroupRule http
resource "aws_security_group_rule" "http_ssh" {
  security_group_id = aws_security_group.ssh.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}