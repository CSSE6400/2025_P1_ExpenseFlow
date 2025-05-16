locals {
  db_username = "administrator"
}

variable "db_password" {
  description = "Password for the database"
}

variable "auth0_domain" {
  description = "Auth0 Domain"
}

variable "auth0_client_id" {
  description = "Auth0 Client ID"
}

variable "auth0_client_secret" {
  description = "Auth0 Client Secret"
}
