variable "db_password" {
  description = "Password for the database"
}

variable "auth0_domain" {
  description = "Auth0 Domain"
}

variable "auth0_client_id" {
  description = "Auth0 M2M Application Client ID"
}

variable "auth0_client_secret" {
  description = "Auth0 M2M Application Client Secret"
}

variable "sentry_dsn" {
  description = "Data source name for sentry plugin"
}
