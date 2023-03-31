# Module definition

provider "google" {
  project = "avian-amulet-378416"
  region  = "northamerica-northeast1-a"
}

module "load_balancer" {
  source = "git::https://github.com/gruntwork-io/terraform-google-load-balancer.git?ref=master"

  name           = "my-http-load-balancer"
  target_tags    = ["web-server"]
  backend_service_port = 80

  http_health_check {
    request_path = "/"
    port         = 80
  }

  backend_service {
    name = "my-backend-service"

    backend {
      group = "my-instance-group"
    }

    timeout_sec = 10
  }
}