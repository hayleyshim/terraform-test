# adding a firewall to the VPC
resource "google_compute_firewall" "firewall_rule" {
  name    = var.firewall_rule_name
  network = var.network

  allow {
    protocol = var.protocol_type
    ports    = var.ports_types
  }
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
