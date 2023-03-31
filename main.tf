# Module definition
module "load_balancer" {
  source = "https://github.com/gruntwork-io/terraform-google-load-balancer"
  project_id = "avian-amulet-378416"
  name       = "alex-balancer"
  region     = "northamerica-northeast1-a"

  enable_http = true #Enable plain http 
  backend_service_port = 80

 # ssl_certificate = {
 #   certificate = "${file("path/to/certificate.pem")}"
 #   private_key = "${file("path/to/private_key.pem")}"
 # }

  target_proxy_url_map = {
    default_service = "http://my-backend-service.default.svc.cluster.local:80"
    map             = null
  }

  global_forwarding_rule = {
    ip_address = null
    port_range = "80"
  }
}