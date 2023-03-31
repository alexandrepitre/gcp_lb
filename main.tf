# Module definition

provider "google" {
  project = "avian-amulet-378416"
  region  = "northamerica-northeast1"
  zone = "northamerica-northeast1-a"
}

module "http-load-balancer" {
  source = "git::https://github.com/GoogleCloudPlatform/terraform-google-lb-http.git?ref=master"
  name = "http-load-balancer"
  region = "northamerica-northeast1"
  zone = "northamerica-northeast1-a"
  network = "alex_net"
  subnetwork = "alex_subnet"
  target_pool_ports = ["80"]
  target_pool_health_check = "tcp-health-check"
  forwarding_rule_name = "http-forwarding-rule"
}