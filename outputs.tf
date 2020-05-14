output "name_servers" {
  value = google_dns_managed_zone.main.name_servers
}

output "router-ip_addresses" {
  value = module.main-vpc.google_compute_address.for_router[*].address
}

output "nat_gateway-ip_address" {
  value = google_compute_instance.nat_gateway.network_interface[0].access_config[0].nat_ip
}

output "step-ip_addresses" {
  value = google_compute_instance.step[*].network_interface[0].access_config[0].nat_ip
}

output "mysql" {
  value = {
    name       = google_sql_database_instance.main-default.name
    ip_address = google_sql_database_instance.main-default.ip_address.0.ip_address
    users = {
      root = format(
        "%s@%s",
        google_sql_user.main-default-root.name,
        google_sql_user.main-default-root.host
      )
      writer = format(
        "%s@%s",
        google_sql_user.main-default-writer.name,
        google_sql_user.main-default-writer.host
      )
      reader = format(
        "%s@%s",
        google_sql_user.main-default-reader.name,
        google_sql_user.main-default-reader.host
      )
    }
  }
}

output "redis" {
  value = {
    host = google_redis_instance.redis[*].host
  }
}
