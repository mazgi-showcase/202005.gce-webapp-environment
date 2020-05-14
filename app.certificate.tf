resource "google_compute_managed_ssl_certificate" "app" {
  provider = google-beta
  name     = "${var.basename}-app"
  managed {
    domains = formatlist(
      "%s${var.basename}.${var.basedomain}",
      local.app_load_balancer_hostnames
    )
  }
}
