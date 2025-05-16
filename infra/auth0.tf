resource "auth0_client" "expenseflow" {
  name                = "expenseflow_app"
  description         = "ExpenseFlow Web App"
  app_type            = "spa" // Flutter is spa, something server-side would be 'spa'
  oidc_conformant     = true
  allowed_logout_urls = []
  allowed_origins     = []
  callbacks           = []
  #   logo_uri            = ""

  jwt_configuration {
    alg = "RS256"
  }
}

data "auth0_client" "expenseflow" {
  name = auth0_client.expenseflow.name
}

data "auth0_tenant" "expenseflow" {}
