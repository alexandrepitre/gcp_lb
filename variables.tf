variable "project" {
  type = string
  default = "avian-amulet-378416"
}

variable "address" {
  type        = string
  description = "Existing IPv4 address to use (the actual IP address value)"
  default     = "global-appserver-ip"
}

variable "http_forward" {
  description = "Set to `false` to disable HTTP port 80 forward"
  type        = bool
  default     = true
}

variable "https_redirect" {
  description = "Set to `true` to enable https redirect on the lb."
  type        = bool
  default     = false
}

variable "backends" {
  description = "Map backend indices to list of backend maps."
  type = map(object({
    port                    = number
    protocol                = string
    port_name               = string
    description             = string
    enable_cdn              = bool
    compression_mode        = string
    security_policy         = string
    custom_request_headers  = list(string)
    custom_response_headers = list(string)

    timeout_sec                     = number
    connection_draining_timeout_sec = number
    session_affinity                = string
    affinity_cookie_ttl_sec         = number

    health_check = object({
      check_interval_sec  = number
      timeout_sec         = number
      healthy_threshold   = number
      unhealthy_threshold = number
      request_path        = string
      port                = number
      host                = string
      logging             = bool
    })

    log_config = object({
      enable      = bool
      sample_rate = number
    })

    groups = list(object({
      group = string

      balancing_mode               = string
      capacity_scaler              = number
      description                  = string
      max_connections              = number
      max_connections_per_instance = number
      max_connections_per_endpoint = number
      max_rate                     = number
      max_rate_per_instance        = number
      max_rate_per_endpoint        = number
      max_utilization              = number
    }))
    iap_config = object({
      enable               = bool
      oauth2_client_id     = string
      oauth2_client_secret = string
    })
  }))
}