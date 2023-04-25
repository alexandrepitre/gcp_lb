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


#Create Global Load Balancer for Serverless NEGs
#https://github.com/terraform-google-modules/terraform-google-lb-http/tree/master/modules/serverless_negs

module "lb-http-serverless" {
  source = "./modules/serverless_negs"

  project = var.project
  name = var.lb_name
  create_address = true
  create_url_map = true

  ssl                             = var.ssl
  managed_ssl_certificate_domains = var.domain_name
  https_redirect                  = var.ssl
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTPS"
      port_name                       = "http"
      edge_security_policy            = null
      security_policy                 = null
      enable_cdn                      = false
      custom_request_headers          = null
      custom_response_headers         = null
      security_policy                 = null
      compression_mode                = null
    
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