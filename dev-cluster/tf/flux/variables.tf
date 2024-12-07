variable "github_token" {
  description = "GitHub token"
  sensitive   = true
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace for Flux"
  type        = string
  default     = "flux-system"
}