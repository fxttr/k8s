module "dev-cluster" {
  source = "./dev-cluster"
  github_token = var.github_token
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.24.0"
    }
  }
}

provider "kubernetes" {
 config_path = "~/.kube/config"
}
