module "dev-cluster" {
  source = "./dev-cluster/tf"
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.24.0"
    }
    sops = {
      source = "carlpett/sops"
      version = ">=1.1.1"
    }
  }
}

provider "kubernetes" {
 config_path = "~/.kube/config"
}

provider "sops" {}