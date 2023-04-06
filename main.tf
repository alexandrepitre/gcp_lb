#Reserved IP Address
#resource "google_compute_global_address" "default" {
#  name = "global-appserver-ip"
#}

# Use an existing Google Cloud Function
data "google_cloudfunctions_function" "my_function" {
  name = "function_v1_mtl"
}

#Serverless Network Endpoint Group (NEG)
resource "google_compute_region_network_endpoint_group" "function_neg" {
  name  = "function-neg"
  network_endpoint_type = "SERVERLESS"
  region = "northamerica-northeast1"
  cloud_function {
    #created manually via UI
    function = "function_v1_mtl"
  }
}

#Create backend service
resource "google_compute_backend_service" "default" {
  name = "serverless-backend-service" 
  load_balancing_scheme = "EXTERNAL"
  protocol = "HTTP"
  timeout_sec = 10
}
# Specify the Cloud Function as the backend
  backend {
    group          = data.google_cloudfunctions_function.my_function.self_link
    balancing_mode = "RATE"
    max_rate_per_instance = 10
  }

# Create a health check to verify the Cloud Function is healthy
  health_checks {
    check_interval_sec = 10
    timeout_sec       = 5
    http_health_check {
      port = 80
      request_path = "/"
    }
  }

# Create a URL map to route requests to the backend service
resource "google_compute_url_map" "default" {
  name            = "url-map-target-proxy"
  default_service = google_compute_backend_service.default.id

  host_rule {
    hosts        = ["mysite.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.default.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.default.id
    }
  }
}

#Conifugre Target Proxy
resource "google_compute_target_http_proxy" "default" {
  name        = "target-proxy"
  description = "a description"
  url_map     = google_compute_url_map.default.id
}



#Forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name = "global-http-forwarding-rule"
  project = "avian-amulet-378416"
  target     = google_compute_target_http_proxy.default.id
  ip_address = "global-appserver-ip"
  port_range = "80"
  load_balancing_scheme = "EXTERNAL"
}


# Module definition
module "lb-http-serverless" {
  source = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 4.4"

  project = "avian-amulet-378416"
  name = "http-load-balancer"

  ssl                             = false
  https_redirect                  = false
  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port_name                       = "HTTP"
      enable_cdn                      = false
      custom_request_headers          = null
      custom_response_headers         = null
      security_policy                 = null


      log_config = {
        enable = false
        sample_rate = 1.0
      }

      groups = [
        {
          # Your serverless service should have a NEG created that's referenced here.
          group = google_compute_region_network_endpoint_group.function_neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}