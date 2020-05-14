# see https://cloud.google.com/load-balancing/docs/https/
variable "gcp_http_load_balancer_source_ipaddr_list" {
  default = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

variable "gcp_project_id" {}

variable "gcp_default_region" {
  default = "asia-northeast1"
}

variable "basename" {}

variable "basedomain" {}

variable "lan_ip_cidr_range" {
  default = "10.0.0.0/24"
}

# Set your specific IP address range for HTTP/HTTPS
variable "cidr_blocks_allow_http" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "cidr_blocks_allow_http_restricted" {
  type    = list(string)
  default = ["127.0.0.0/8"]
}
variable "http_restricted_path_regexp" {
  default = "/restricted/"
}

# Set your specific IP address range for SSH
variable "cidr_blocks_allow_ssh" {
  type = list(string)
}

variable "cloud_sql_root_password" {}

variable "cloud_sql_writer_username" {
  default = "writer"
}

variable "cloud_sql_writer_password" {}

variable "cloud_sql_reader_username" {
  default = "reader"
}

variable "cloud_sql_reader_password" {}

variable "github_accounts_for_ssh" {
  type = list(string)
}
