# See https://cloud.google.com/load-balancing/docs/https/

resource "google_compute_global_address" "app-lb" {
  name = "${var.basename}-app-lb"
}

resource "google_dns_record_set" "app-lb" {
  count = length(local.app_load_balancer_hostnames)

  name = format(
    "%s%s.%s.",
    element(local.app_load_balancer_hostnames, count.index),
    var.basename,
    var.basedomain
  )

  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    google_compute_global_address.app-lb.address
  ]
}

# --------------------------------
# Forwarding rules configuration

resource "google_compute_global_forwarding_rule" "app-https" {
  name       = "${var.basename}-app-https"
  target     = google_compute_target_https_proxy.app.self_link
  ip_address = google_compute_global_address.app-lb.address
  port_range = 443
}

resource "google_compute_global_forwarding_rule" "app-http" {
  name       = "${var.basename}-app-http"
  target     = google_compute_target_http_proxy.app.self_link
  ip_address = google_compute_global_address.app-lb.address
  port_range = 80
}

# --------------------------------
# Target proxies configuration

resource "google_compute_target_https_proxy" "app" {
  name             = "${var.basename}-app"
  url_map          = google_compute_url_map.app.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.app.self_link]
}

resource "google_compute_target_http_proxy" "app" {
  name    = "${var.basename}-app"
  url_map = google_compute_url_map.app.self_link
}

# --------------------------------
# URL map configuration

resource "google_compute_url_map" "app" {
  name            = "${var.basename}-app"
  default_service = google_compute_backend_service.app.self_link
  host_rule {
    hosts        = ["${var.basename}.${var.basedomain}"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.app.self_link
    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.app.self_link
    }
  }
}

# --------------------------------
# Backend configuration

resource "google_compute_backend_service" "app" {
  name = "${var.basename}-app"
  backend {
    group = google_compute_instance_group.app.self_link
  }
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30
  health_checks = [
    google_compute_http_health_check.app.self_link
  ]
  security_policy = google_compute_security_policy.main.self_link
}

resource "google_compute_http_health_check" "app" {
  name               = "${var.basename}-app"
  request_path       = "/"
  port               = 80
  check_interval_sec = 10
  timeout_sec        = 10
}
