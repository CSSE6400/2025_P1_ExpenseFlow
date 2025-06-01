data "aws_route53_zone" "expenseflow" {
  name         = "g3.csse6400.xyz"
  private_zone = false
}

resource "aws_route53_record" "expenseflow_ui" {
  zone_id = data.aws_route53_zone.expenseflow.zone_id
  name    = "expenseflow.g3.csse6400.xyz"
  type    = "A"
  alias {
    name                   = "dualstack.${aws_lb.expenseflow_ui.dns_name}"
    zone_id                = aws_lb.expenseflow_ui.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "expenseflow_api" {
  zone_id = data.aws_route53_zone.expenseflow.zone_id
  name    = "expenseflow-api.g3.csse6400.xyz"
  type    = "A"
  alias {
    name                   = "dualstack.${aws_lb.expenseflow_api.dns_name}"
    zone_id                = aws_lb.expenseflow_api.zone_id
    evaluate_target_health = true
  }
}
