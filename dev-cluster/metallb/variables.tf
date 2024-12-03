variable "metallb_version" {
  default     = "0.14.8"
  type        = string
  description = "MetalLB Version e.g. 0.14.8"
}

variable "controller_toleration" {
  default = []
  type    = list(map(any))
}

variable "controller_node_selector" {
  default = {}
  type    = map(any)
}