#module "metallb" {
#  source = "./metallb"
#  metallb_version = "0.14.8"
#}

module "flux" {
  source = "./flux"
  github_token = data.sops_file.sops-secret.data["github_token"]
}

terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
      version = ">=1.1.1"
    }
  }
}
