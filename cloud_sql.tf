resource "random_id" "main-default-name-suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "main-default" {
  name             = "main-default-${random_id.main-default-name-suffix.hex}"
  region           = var.gcp_default_region
  database_version = "MYSQL_5_7"

  settings {
    tier              = "db-n1-standard-1"
    disk_size         = 10
    disk_type         = "PD_SSD"
    activation_policy = "ALWAYS"
    disk_autoresize   = true
    replication_type  = "SYNCHRONOUS"
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "00:00"
    }

    ip_configuration {
      ipv4_enabled = true
      require_ssl  = true

      dynamic "authorized_networks" {
        for_each = google_compute_instance.step
        iterator = step

        content {
          name  = step.value.name
          value = step.value.network_interface.0.access_config.0.nat_ip
        }
      }

      dynamic "authorized_networks" {
        for_each = google_compute_instance.app
        iterator = app

        content {
          name  = app.value.name
          value = app.value.network_interface.0.access_config.0.nat_ip
        }
      }
    }

    location_preference {
      zone = "${var.gcp_default_region}-a"
    }
  }
}

resource "google_sql_user" "main-default-root" {
  name     = "root"
  instance = google_sql_database_instance.main-default.name
  host     = "%"
  password = var.cloud_sql_root_password
}

resource "google_sql_user" "main-default-writer" {
  name     = var.cloud_sql_writer_username
  instance = google_sql_database_instance.main-default.name
  host     = "%"
  password = var.cloud_sql_writer_password
}

resource "google_sql_user" "main-default-reader" {
  name     = var.cloud_sql_reader_username
  instance = google_sql_database_instance.main-default.name
  host     = "%"
  password = var.cloud_sql_reader_password
}
