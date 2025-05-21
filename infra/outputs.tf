resource "local_file" "ui_url" {
  content  = local.ui_url
  filename = "./ui.txt"
}

resource "local_file" "api_url" {
  content  = local.api_url
  filename = "./api.txt"
}
