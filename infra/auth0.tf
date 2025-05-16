data "auth0_tenant" "expenseflow" {}

resource "auth0_client" "expenseflow_ui_client" {
  name                = "ExpenseFlow UI Client"
  description         = "ExpenseFlow UI Client"
  app_type            = "spa" // Flutter is spa, something server-side would be 'spa'
  oidc_conformant     = true
  allowed_logout_urls = []
  allowed_origins     = []
  callbacks           = []
  web_origins         = []
  #   logo_uri            = ""

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

data "auth0_client" "expenseflow" {
  name = auth0_client.expenseflow.name
}

resource "auth0_resource_server" "expenseflow_api" {
  name                   = "ExpenseFlow Backend"
  identifier             = "https://expenseflow/api"
  signing_alg            = "RS256"
  token_dialect          = "access_token"
  token_lifetime         = 86400
  token_lifetime_for_web = 7200
  allow_offline_access   = true
}
