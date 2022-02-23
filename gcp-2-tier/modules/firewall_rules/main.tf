# adding a firewall to the VPC
resource "google_compute_firewall" "firewall_rule" {
  name    = var.firewall_rule_name
  network = var.network
  #name          = var.name #webserver 추가
  #source_ranges = var.source-ranges #webserver 추가

  allow {
    protocol = var.protocol_type
    ports    = var.ports_types
  }
  #webserver 추가
  #log_config {
  #  metadata = "INCLUDE_ALL_METADATA"
  #}
  source_tags = var.source_tags
  source_ranges = var.source_ranges
  target_tags = var.target_tags
}

###########################################
#                                         #
#         Webserver RESOURCES 추가         # 
#                                         #
###########################################

resource "google_compute_firewall" "this" {
  name          = var.name
  network       = var.network
  source_ranges = var.source-ranges

  allow {
    protocol = var.ip_protocol
    ports    = [var.backend-port]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

}
