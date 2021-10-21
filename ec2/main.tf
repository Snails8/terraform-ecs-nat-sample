# =======================================================
# EC2
# 1. Amazon マシンイメージ (AMI) 選択
# 2. インスタンスタイプの選択: ex) t2.micro
# 3. インスタンス詳細設定: VPC選択, subnet選択, etc..
# 4. ストレージの選択: volume_type:汎用SSD(gp2) , サイズ:xxGB, IOPS, スループット
# 5. tag_name
# 6. セキュリティーグループの選択: type(ssh), port, source
# 7. 任意、キーペアの作成
# 8. ElasticIP(EIP) の用意
# =======================================================

# ========================================================
# AMI 最新のイメージの取得 (filter で絞っている
# ========================================================
data "aws_ami" "recent_amazon_linux2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

# ========================================================
# EC2
# ami選択: Amazon Machine Image  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html
# instance type 指定 ex) t2.micro(free)
# key_name : キーペア
# EBS ストレージの設定 *1
# tag_name
# セキュリティーグループ

# *1 EBS:Elastic Block Store EC2向けに設計,EC2インスタンスにアタッチして使われるAWSのストレージサービス
# EBS最適化: EC2インスタンスを作成するときは、ebs_optimizedの指定を気にしなくてもよい trueにするとコケる
# ========================================================

resource "aws_instance" "main" {
  ami = data.aws_ami.recent_amazon_linux2.image_id
  instance_type = "t2.micro"
  key_name = aws_key_pair.main.id

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id = var.subnet_id

  # EBS最適化
  # ebs_optimized = true

  # EBSの設定
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    delete_on_termination = true

    tags = {
      Name = var.app_name
    }
  }

  tags = {
    Name = var.app_name
  }
}
# ========================================================
# SecurityGroup
# name, description, vpc_id, Rule, egress,
# terraform での作成の場合、GUIでは自動で設定してくれるアウトバウンドを設定する必要がある(GUIの default は有効)
# outbound 機器から外部に出力されるパケットをエグレス 上り
# -1 にすればterraform側で勝手に オールにする https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#egress
# ========================================================
resource "aws_security_group" "main" {
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
resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.main.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# SecurityGroupRule http
resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.main.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

# SSHKey (ssh-keygen -t rsa で発行したpub-key を指定)
resource "aws_key_pair" "main" {
  key_name   = "sample-ec2-key"
  public_key = file("./ec2/sample-ec2-key.pub")
}

# EIP (ElasticIP)
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  vpc      = true

  tags = {
    Name = var.app_name
  }
}