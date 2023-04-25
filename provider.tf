provider "google" {
  project = var.project
  region  = "${var.region[0]}"
}
