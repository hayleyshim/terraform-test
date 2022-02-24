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


resource "google_compute_instance_template" "application-template" {
  name_prefix="${var.instance_name}-template"
  machine_type="f1-micro"
  region="${var.region}"

  disk {
    source_image="${var.machine_image}"
  }

  network_interface {
    subnetwork = var.subnetwork

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

resource "google_compute_instance_group_manager" "application-igm" {
  name               = "${var.instance_name}-instance-group-manager"
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


resource "google_compute_backend_service" "application-be" {
  name        = "${var.instance_name}-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.application-igm.instance_group}"
  }

  health_checks = ["${google_compute_http_health_check.application-http-healthcheck.self_link}"]
}

resource "google_compute_http_health_check" "application-http-healthcheck" {
  name               = "${var.instance_name}-http-healthcheck"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_target_http_proxy" "application-proxy" {
  name        = "${var.instance_name}-proxy"
  description = "a description"
  url_map     = "${google_compute_url_map.application-url-map.self_link}"
}

resource "google_compute_url_map" "application-url-map" {
  name        = "${var.instance_name}-url-map"
  description = "a description"

  default_service = "${google_compute_backend_service.application-be.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.application-be.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.application-be.self_link}"
    }
  }

}

resource "google_compute_global_forwarding_rule" "application-forwarding-rule" {
  name       = "${var.instance_name}-fwd-rule"
  target     = "${google_compute_target_http_proxy.application-proxy.self_link}"
  port_range = "80"
}
