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