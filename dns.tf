data "aws_route53_zone" "main" {
  name = var.dns_name
}


resource "aws_route53_zone" "employee" {
  name          = "work.${var.dns_name}"
  force_destroy = true
}


resource "aws_route53_record" "employee_entrance" {
  zone_id = data.aws_route53_zone.main.zone_id
  type    = "NS"
  ttl     = "30"
  name    = aws_route53_zone.employee.name
  records = aws_route53_zone.employee.name_servers
}
