resource "aws_vpc_endpoint" "s3" {

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
    "Name" = "${var.app_name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = length(var.private_subnets)
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = var.private_route_table[count.index].route_table_id
}

# ================================================================
# Interface型なので各種セキュリティグループと紐づく
# ================================================================
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.ecs.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.app_name}-private-ECR_DKR"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.ecs.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.app_name}-private-ECR_API"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.ecs.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.app_name}-private-logs"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.ecs.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.app_name}-private-ssm"
  }
}
resource "aws_vpc_endpoint" "ses" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.qldb.session"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [aws_security_group.ecs.id]
  private_dns_enabled = true
  tags = {
    "Name" = "${var.app_name}-private-ses"
  }
}