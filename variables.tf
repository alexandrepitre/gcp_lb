variable "project" {
  type = string
}

variable "prefix" {
  type = string
}

variable "domain_name" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type = list
}

variable "zone_name" {
  default = "cn-com"
}

variable "function_name" {
  type = string
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type = bool
}

variable "lb_name" {
  description = "Name for load balancer and associated resources"
  type = string
}

variable "region_neg1" {
  description = "Region of the first network endpoint group"
  default     = "northamerica-northeast1"
}

variable "region_neg2" {
  description = "Region of the second network endpoint group"
  default     = "us-central1"
}