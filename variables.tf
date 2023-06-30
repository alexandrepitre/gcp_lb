variable "project_id" {
  type = string
}

variable "prefix" {
  type = string
}

variable "domain_name" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type = list(string)
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

variable "region" {
type = list(string) 
}