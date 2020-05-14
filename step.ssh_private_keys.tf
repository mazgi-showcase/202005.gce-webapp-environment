resource "tls_private_key" "ssh_private_key-root" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}
