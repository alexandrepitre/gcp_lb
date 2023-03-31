# Module definition

provider "google" {
  project = "avian-amulet-378416"
  region  = "northamerica-northeast1"
  zone = "northamerica-northeast1-a"
}

module "http-load-balancer" {
  source  = "terraform-google-modules/http-load-balancer/google"
  version = "v1.4.0"
  name               = "http-load-balancer"
  region  = "northamerica-northeast1"
  zone = "northamerica-northeast1-a"
  network            = "alex_net"
  subnetwork         = "alex_subnet"
  target_pool_ports  = ["80"]
  target_pool_health_check = "tcp-health-check"
  forwarding_rule_name = "http-forwarding-rule"
}