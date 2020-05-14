resource "google_compute_address" "app" {
  count = 2
  name  = "${var.basename}-app-${count.index + 1}"
}

# --------------------------------
# Google Compute Engine instance configuration

resource "google_compute_instance" "app" {
  count = length(google_compute_address.app)

  name         = "${var.basename}-app-${count.index + 1}"
  zone         = "${var.gcp_default_region}-a"
  machine_type = "n1-standard-1"

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  // NOTE: The `network` is cannot work if you using "custom subnetmode network", you should set the `subnetwork` instead of the `network`.
  network_interface {
    subnetwork = module.main-vpc.google_compute_subnetwork.main[0].self_link
    access_config {
      nat_ip = google_compute_address.app[count.index].address
    }
  }

  metadata = {
    ssh-keys = format("root:%s", tls_private_key.ssh_private_key-root.public_key_openssh)
  }
  metadata_startup_script = <<-EOF
  #!/bin/bash -eu
  apt-get update
  apt-get install --assume-yes --no-install-recommends nginx
  EOF

  tags = concat(
    module.main-vpc.google_compute_firewall.ingress-allow-any.target_tags[*],
    module.main-vpc.google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags[*],
    google_compute_firewall.ingress-allow-custom-ports-from-lb.target_tags[*],
    ["${local.tag_apply_route_main_default_prefix}-all"],
  )
}
