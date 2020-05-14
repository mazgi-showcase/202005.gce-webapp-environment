module "main-vpc" {
  source   = "mazgi/simple-vpc/google"
  version  = "2019.12.0"
  basename = var.basename
  cidr_blocks_subnetworks = {
    "${var.lan_ip_cidr_range}" = var.gcp_default_region
  }
  cidr_blocks_allow_ssh = concat(
    list(var.lan_ip_cidr_range),
    var.cidr_blocks_allow_ssh,
    google_compute_address.step[*].address # for gcloud ssh command
  )
}
