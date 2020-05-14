resource "google_compute_address" "nat_gateway" {
  name = "${var.basename}-nat-gateway"
}

# --------------------------------
# Google Compute Engine instance configuration

resource "google_compute_instance" "nat_gateway" {
  name         = "${var.basename}-nat-gateway"
  zone         = "${var.gcp_default_region}-a"
  machine_type = "n1-standard-1"

  can_ip_forward            = true # to use routing
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
      nat_ip = google_compute_address.nat_gateway.address
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
  metadata_startup_script = <<-EOF
  #!/bin/bash -eu
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
  EOF

  tags = concat(
    module.main-vpc.google_compute_firewall.ingress-allow-any.target_tags[*],
    module.main-vpc.google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags[*],
  )
}
