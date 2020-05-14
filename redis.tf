resource "google_redis_instance" "redis" {
  count = 1

  name               = "${var.basename}-redis-${count.index + 1}"
  redis_version      = "REDIS_4_0"
  memory_size_gb     = 1
  location_id        = "${var.gcp_default_region}-a"
  authorized_network = module.main-vpc.google_compute_network.main.self_link
}
