resource "google_compute_security_policy" "main" {
  name = "${var.basename}-main"

  # (deny) fallback
  rule {
    action   = "deny(403)"
    priority = 2147483647 # INT32_MAX
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  # (allow) other paths
  rule {
    action   = "allow"
    priority = 2000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.cidr_blocks_allow_http
      }
    }
  }
}
