resource "google_compute_instance" "virtual-machine" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.vm_zone

  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = var.machine_image
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    Name = var.metadata_Name_value
  }
}  

###########################################
#                                         #
#         Webserver RESOURCES 추가         # 
#                                         #
###########################################


resource "google_compute_instance" "this" {
  name                    = var.name
  machine_type            = var.vm-type
  metadata_startup_script = var.vm-startup-script
  boot_disk {
    initialize_params {
      image = var.vm-image
    }
  }
  network_interface {
    network = var.network
    #tfsec:ignore:google-compute-no-public-ip
    access_config {
    }
  }
}

resource "google_compute_instance_group" "this" {
  name      = var.name
  instances = [google_compute_instance.this.id]
  named_port {
    name = var.name
    port = var.backend-port
  }
}

resource "google_compute_health_check" "this" {
  name               = var.name
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = var.backend-port
  }
}

resource "google_compute_backend_service" "this" {
  name                  = var.name
  provider              = google-beta
  protocol              = "HTTP"
  port_name             = var.name
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.this.id]
  backend {
    group           = google_compute_instance_group.this.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_global_address" "this" {
  name = var.name
}

resource "google_compute_global_forwarding_rule" "this" {
  name                  = var.name
  ip_protocol           = upper(var.ip_protocol)
  load_balancing_scheme = "EXTERNAL"
  port_range            = var.frontend-port
  target                = google_compute_target_http_proxy.this.id
  ip_address            = google_compute_global_address.this.id
}

resource "google_compute_target_http_proxy" "this" {
  name    = var.name
  url_map = google_compute_url_map.this.id
}

resource "google_compute_url_map" "this" {
  name            = var.name
  default_service = google_compute_backend_service.this.id
}


