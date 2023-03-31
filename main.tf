# Module definition
module "load_balancer" {
  source = "terraform-google-modules/http-load-balancer/google"
  project_id = "avian-amulet-378416"
  name       = "alex-balancer"
  region     = "northamerica-northeast1-a"

  enable_http = true #Enable plain http 
  backend_service_port = 80
  target_proxy_url_map = {
    default_service = "http://my-backend-service.default.svc.cluster.local:80"
    map             = null
  }

  global_forwarding_rule = {
    ip_address = null
    port_range = "80"
  }
}