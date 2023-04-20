variable "project" {
  type = string
  default = "avian-amulet-378416"
}

variable "prefix" {
  default = "alex"
}

variable "domain_name" {
  type = list
  default = ["alex.cn.com"]
}

variable "zone_name" {
  default = "cn-com"
}