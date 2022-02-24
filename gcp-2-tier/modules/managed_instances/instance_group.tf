
resource "google_compute_instance_template" "application-template" {
  name_prefix="${var.prefix}-template"
  machine_type="f1-micro"
  region="${var.region}"

  disk {
    source_image="${var.machine_image}"
  }

  network_interface {
    network="default"

    access_config {
      // Ephemeral IP
      // creates an external IP, remove to keep internal only
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "application-healthcheck" {
  name                = "${var.prefix}-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10                         # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_instance_group_manager" "application-igm" {
  name               = "${var.prefix}-instance-group-manager"
  instance_template  = "${google_compute_instance_template.application-template.self_link}"
  base_instance_name = "${var.instance_name}"
  zone               = "${var.vm_zone}"
  target_size        = "5"
  update_strategy    = "NONE"
  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = "${google_compute_health_check.application-healthcheck.self_link}"
    initial_delay_sec = 300
  }

}
