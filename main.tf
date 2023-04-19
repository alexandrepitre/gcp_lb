#Serverless Network Endpoint Group (NEG)
#resource "google_compute_region_network_endpoint_group" "function_neg" {
#  name  = "function-neg"
#  network_endpoint_type = "SERVERLESS"
#  region = "northamerica-northeast1"
#  cloud_function {
#    #created manually via UI
#    function = "function_v1_mtl"
#  }
#}

#Create Serverless Network Endpoint Group (NEG)
module "neg_northamerica_northeast1" {
  source = "./modules/neg"
  prefix        = var.prefix
  region        = "northamerica-northeast1"
  function_name = "function_v1_mtl"

}

module "neg_us_central1" {
  source = "./modules/neg"
  prefix        = var.prefix
  region        = "us-central1"
  function_name = "function_v1_mtl"
}


#Create Global Load Balancer for Serverless NEGs
#https://github.com/terraform-google-modules/terraform-google-lb-http/tree/master/modules/serverless_negs

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