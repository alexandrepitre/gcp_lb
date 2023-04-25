variable "project" {
  type = string
  default = "avian-amulet-378416"
}

variable "prefix" {
  default = "alex"
}

variable "domain_name" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type = list
  default = ["alex.cn.com"]
}

variable "zone_name" {
  default = "cn-com"
}

variable "function_name" {
  default = "function_v1_mtl"
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "lb_name" {
  description = "Name for load balancer and associated resources"
  default     = "alex-load-balancer"
}