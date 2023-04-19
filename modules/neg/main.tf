resource "google_compute_region_network_endpoint_group" "function_neg" {
  name                  = "${var.prefix}-${var.region}-fct-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_function {
    function = var.function_name
  }
}
