data "auth0_tenant" "expenseflow" {}

data "aws_s3_object" "expenseflow_logo" {
  bucket = "expenseflow-assets"
  key    = "auth0_logo.png"
}

resource "auth0_client" "expenseflow_ui_client" {
  name                = "ExpenseFlow UI Client"
  description         = "ExpenseFlow UI Client"
  app_type            = "spa"
  oidc_conformant     = true
  is_first_party      = true
  allowed_logout_urls = [local.ui_url]
  allowed_origins     = [local.ui_url]
  web_origins         = [local.ui_url]
  callbacks           = [local.ui_url]
  grant_types         = ["authorization_code", "refresh_token"]

  logo_uri = "https://${data.aws_s3_object.expenseflow_logo.bucket}.s3.amazonaws.com/${data.aws_s3_object.expenseflow_logo.key}"

  depends_on = [aws_route53_record.expenseflow_ui]

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
    scopes              = {}
    secret_encoded      = false
  }

  refresh_token {
    expiration_type              = "expiring"
    idle_token_lifetime          = 1296000
    infinite_idle_token_lifetime = false
    infinite_token_lifetime      = false
    leeway                       = 0
    rotation_type                = "rotating"
    token_lifetime               = 2592000
  }

}

data "auth0_client" "expenseflow_ui_client" {
  name = auth0_client.expenseflow_ui_client.name
}

resource "auth0_resource_server" "expenseflow_api" {
  name                   = "ExpenseFlow API"
  identifier             = "https://expenseflow.com/prd/api"
  signing_alg            = "RS256"
  token_dialect          = "access_token"
  token_lifetime         = 86400
  token_lifetime_for_web = 7200
  allow_offline_access   = true
}


data "auth0_resource_server" "expenseflow_api" {
  identifier = auth0_resource_server.expenseflow_api.identifier
}

resource "aws_secretsmanager_secret" "auth0_details" {
  name = "auth0-details"
}

resource "aws_secretsmanager_secret_version" "auth0_details" {
  secret_id = aws_secretsmanager_secret.auth0_details.id
  secret_string = jsonencode(
    {
      domain        = var.auth0_domain
      client_id     = data.auth0_client.expenseflow_ui_client.client_id
      client_secret = data.auth0_client.expenseflow_ui_client.client_secret
      identifier    = auth0_resource_server.expenseflow_api.identifier
    }
  )
}

