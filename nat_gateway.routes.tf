resource "google_compute_route" "main-default" {
  for_each = toset([
    "104.24.122.146/32", # ifconfig.io
  ])

  name = format(
    "%s-main-to-%s",
    var.basename,
    replace(replace(each.key, "//[0-9]+/", ""), ".", "-")
  )
  dest_range = each.value

  network                = module.main-vpc.google_compute_network.main.self_link
  next_hop_instance      = google_compute_instance.nat_gateway.name
  next_hop_instance_zone = "${var.gcp_default_region}-a"
  tags = [
    "${local.tag_apply_route_main_default_prefix}-all",
    format(
      "%s-%s",
      local.tag_apply_route_main_default_prefix,
      replace(replace(each.key, "//[0-9]+/", ""), ".", "-")
    ),
  ]
}
