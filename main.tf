#Create Serverless Network Endpoint Group (NEG)
module "neg_northamerica_northeast1" {
  source = "./modules/neg"
  prefix        = var.prefix
  region        = "${var.region[0]}"
  function_name = var.function_name

}

module "neg_us_central1" {
  source = "./modules/neg"
  prefix        = var.prefix
  region        = "${var.region[1]}"
  function_name = var.function_name
}


#Create url map 
resource "google_compute_url_map" "urlmap" {
  name = "urlmap"
  default_service = module.lb-http-serverless.backend_services["default"].self_link

  host_rule {
    hosts        = ["test.cn.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = module.lb-http-serverless.backend_services["default"].self_link

    path_rule {
      paths = ["/order"]
      service = module.lb-http-serverless.backend_services["default"].self_link
    }

    path_rule {
      paths = ["/user"]
      service = module.lb-http-serverless.backend_services["default"].self_link
    }
  }
}

#Create Global Load Balancer for Serverless NEGs
#https://github.com/terraform-google-modules/terraform-google-lb-http/tree/master/modules/serverless_negs
module "lb-http-serverless" {
  source = "./modules/serverless_negs"

  project = var.project_id
  name = var.lb_name
  create_address = true
  #create_url_map = yes

  ssl                             = var.ssl
  managed_ssl_certificate_domains = var.domain_name
  https_redirect                  = var.ssl
  load_balancing_scheme = "EXTERNAL_MANAGED"
  url_map = google_compute_url_map.urlmap.self_link

  backends = {
    default = {
      protocol                        = "HTTPS"
      port_name                       = "http"
      description                     = null
      enable_cdn                      = false
      security_policy                 = null
      compression_mode                = null
      edge_security_policy            = null
      custom_request_headers          = null
      custom_response_headers         = null
    
      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        {
          #Attach NEG1 to backend
          group = module.neg_northamerica_northeast1.neg_id
        },

        {
          #Attach NEG2 to backend
          group = module.neg_us_central1.neg_id
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