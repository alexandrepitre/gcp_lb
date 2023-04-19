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

# Module definition
module "lb-http-serverless" {
  source = "./modules/serverless_negs"

  project = var.project
  name = "alex-load-balancer"
  create_address = true
  create_url_map = true

  ssl                             = true
  managed_ssl_certificate_domains = ["cn.com"]
  https_redirect                  = true
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backends = {
    default = {
      protocol                        = "HTTPS"
      port_name                       = "HTTPS"
      enable_cdn                      = false

      groups = [
        {
          # Your serverless service should have a NEG created that's referenced here.
          group = google_compute_region_network_endpoint_group.function_neg.id
        }
      ]
    }
  }
}