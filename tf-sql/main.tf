variable "appuser_password" {
  type        = string
  description = "password for DB user"
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "site-db" {
  name             = "site-db"
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "appuser" {
  name     = "appuser"
  instance = google_sql_database_instance.site-db.name
  host     = "me.com"
  password = var.appuser_password
}