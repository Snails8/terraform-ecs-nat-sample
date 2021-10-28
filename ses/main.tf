# =================================================
# route53 zoneに関しては運用時変更してください
# メール送信に使用
# =================================================

# ドメインと関連するホストゾーンが存在しないのでresource
data "aws_route53_zone" "main" {
  name         = var.zone
  private_zone = false
}

# SESドメインIDリソースの提供
resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

# SES電子メールIDリソースを提供
resource "aws_route53_record" "ses_record" {
  zone_id = data.aws_route53_zone.main.id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = aws_ses_domain_identity.ses.verification_token
}

# SESドメインIDの検証が成功したことを表わす
resource "aws_ses_domain_identity_verification" "domain_verification" {
  domain     = aws_ses_domain_identity.ses.id
  depends_on = [aws_route53_record.ses_record]
}

# SESドメインDKIM生成リソースを提供
resource "aws_ses_domain_dkim" "dkim" {
  domain = var.domain
}

#  SESドメインDKIMのレコードリソースの作成
resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.main.id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}