resource "google_compute_address" "step" {
  count = 1
  name  = "${var.basename}-step-${count.index + 1}"
}

resource "google_dns_record_set" "step" {
  count = length(google_compute_address.step)

  name = format(
    "step-%d.%s.%s.",
    count.index + 1,
    var.basename,
    var.basedomain
  )

  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    google_compute_address.step[count.index].address
  ]
}

# --------------------------------
# Google Compute Engine instance configuration

data "template_file" "step-metadata_startup_script" {
  template = file("${path.module}/step.metadata_startup_script.template.sh")
  vars = {
    private_key_pem = tls_private_key.ssh_private_key-root.private_key_pem
  }
}

resource "google_compute_instance" "step" {
  count = length(google_compute_address.step)

  name         = "${var.basename}-step-${count.index + 1}"
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
      nat_ip = google_compute_address.step[count.index].address
    }
  }

  service_account {
    email = google_service_account.step.email
    scopes = [
      "cloud-platform",
      "compute-rw",
    ]
  }

  metadata = {
    ssh-keys = data.null_data_source.metadata_all_users_sshkeys_from_user_sshkeys.outputs.sshkeys
  }
  metadata_startup_script = data.template_file.step-metadata_startup_script.rendered

  tags = concat(
    module.main-vpc.google_compute_firewall.ingress-allow-any.target_tags[*],
    module.main-vpc.google_compute_firewall.ingress-allow-ssh-from-specific-ranges.target_tags[*],
    ["${local.tag_apply_route_main_default_prefix}-all"],
  )
}
