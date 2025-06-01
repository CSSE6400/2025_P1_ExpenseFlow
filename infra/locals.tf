locals {
  db_username = "administrator"
  ui_url      = "https://${aws_route53_record.expenseflow_ui.name}"
  api_url     = "https://${aws_route53_record.expenseflow_api.name}"
}
