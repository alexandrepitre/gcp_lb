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

module "backend_service" {
  source = "terraform-google-modules/serverless-backend/google"
  name   = "backend-service"
  type   = "cloud-run"

  cloud_run_service_name = "my-cloud-run-service"
  cloud_run_region       = "us-central1"
}

module "url_map" {
  source         = "terraform-google-modules/http-load-balancer/google"
  version        = "v4.0.0"
  name           = "url-map"
  default_service_backend = {
    description           = "The backend service for the URL map"
    backend_service       = module.backend_service.backend_service_id
    timeout_sec           = 10
  }

  host_rules = [
    {
      hosts       = ["example.com"]
      path_matcher = "path-matcher"
    }
  ]

  path_matchers = [
    {
      name            = "path-matcher"
      default_service = module.backend_service.backend_service_id
      path_rules = [
        {
          paths   = ["/"]
          service = module.backend_service.backend_service_id
        }
      ]
    }
  ]
}

module "global_forwarding_rule" {
  source              = "terraform-google-modules/http-load-balancer/google"
  version             = "v4.0.0"
  name                = "global-forwarding-rule"
  ip_address          = "global-appserver-ip"
  port_range          = "80"
  load_balancing_scheme = "EXTERNAL"
  target              = module.url_map.target_self_link
}