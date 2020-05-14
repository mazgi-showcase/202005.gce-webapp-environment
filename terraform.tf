# --------------------------------
# Terraform configuration

terraform {
  required_version = "0.12.24"

  required_providers {
    google      = "3.20.0"
    google-beta = "3.20.0"
  }

  backend "gcs" {
    prefix = "default/terraform"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = "${var.gcp_default_region}-a"
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = "${var.gcp_default_region}-a"
}

# https://www.terraform.io/docs/providers/google/guides/version_3_upgrade.html#google_project_services-has-been-removed-from-the-provider
resource "google_project_service" "service" {
  for_each = toset([
    "appengine.googleapis.com", # for `gcloud domains list-user-verified`
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "redis.googleapis.com",
    "sqladmin.googleapis.com",
  ])

  service = each.key

  project            = var.gcp_project_id
  disable_on_destroy = false
}
