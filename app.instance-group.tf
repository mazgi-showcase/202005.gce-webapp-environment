resource "google_compute_instance_group" "app" {
  name      = "${var.basename}-app"
  instances = google_compute_instance.app[*].self_link
  named_port {
    name = "http"
    port = "80"
  }
}
