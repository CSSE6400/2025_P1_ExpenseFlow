locals {
  db_username = "administrator"
  ui_url      = "http://${aws_lb.expenseflow_ui.dns_name}"
}
