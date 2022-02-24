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

#health check 추가
resource "google_compute_health_check" "application-healthcheck" {
  name                = "${var.instance_name}-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10                         # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}
