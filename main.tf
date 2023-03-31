# Module definition

provider "google" {
  project = "avian-amulet-378416"
  region  = "northamerica-northeast1"
}

module "load_balancer" {
  source = "git::https://github.com/gruntwork-io/terraform-google-load-balancer.git?ref=master"
  project = "avian-amulet-378416"
  name = "my-http-load-balancer"
  region  = "northamerica-northeast1"
  zone = "northamerica-northeast1-a"
  enable_http = true
}