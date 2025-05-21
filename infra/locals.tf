locals {
  db_username = "administrator"
  ui_url      = "http://${aws_lb.expenseflow_ui.dns_name}"
  api_url     = "http://${aws_lb.expenseflow_api.dns_name}"
}
