resource "local_file" "ui_url" {
  content  = local.ui_url
  filename = "./ui.txt"
}

resource "local_file" "api_url" {
  content  = "http://${aws_lb.expenseflow_api.dns_name}"
  filename = "./api.txt"
}
