# Module definition
/* 
  module "gce-lb-http" {
  source = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project = "avian-amulet-378416"
  name = "http-load-balancer"

  target_tags       = [module.mig1.target_tags, module.mig2.target_tags]
  backends = {
    default = {
      description                     = null
      port                            = var.service_port
      protocol                        = "HTTP"
      port_name                       = var.service_port_name
      timeout_sec                     = 10
      enable_cdn                      = false
      custom_request_headers          = null
      custom_response_headers         = null
      security_policy                 = null
      compression_mode                = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = var.service_port
        host                = null
        logging             = null
      }

      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = var.backend
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
} 
*/

module "http_load_balancer" {
  source  = "terraform-google-modules/lb-http/google"
  name               = "global-http-lb"
  project_id = "avian-amulet-378416"
  region  = "northamerica-northeast1-a"
  backend_service    = "serverless-backend-service"
  ip_address         = "global-appserver-ip"
  http_health_check  = true
  https_redirect     = true
  ssl_policy         = "MODERN"
  security_policy    = "basic"
  target_proxy       = "global-http-proxy"
  url_map            = "global-http-url-map"
}

resource "google_compute_backend_service" "serverless_backend_service" {
  name                 = "serverless-backend-service"
  project = "avian-amulet-378416"
  load_balancing_scheme = "INTERNAL_SELF_MANAGED"
  protocol             = "HTTP"
  backends {
    description = "Serverless Backend"
  }
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "global-http-forwarding-rule"
  ip_address = "global-appserver-ip"
  port_range = "80"
  target    = "${google_compute_target_http_proxy.global_http_proxy.self_link}"
  project = "avian-amulet-378416"
}

resource "google_compute_target_http_proxy" "global_http_proxy" {
  name    = "global-http-proxy"
  project = "avian-amulet-378416"
  url_map = "${google_compute_url_map.global_http_url_map.self_link}"
}

resource "google_compute_url_map" "global_http_url_map" {
  name            = "global-http-url-map"
  default_service = "${google_compute_backend_service.serverless_backend_service.self_link}"
  project = "avian-amulet-378416"
}