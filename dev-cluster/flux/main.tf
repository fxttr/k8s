terraform {
  required_version = ">= 1.7.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
  }
}

resource "github_repository" "this" {
  name        = "k8s"
  description = "My k8s development cluster @ home"
  visibility  = "public"
  auto_init   = false
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.this]
  namespace = var.namespace

  embedded_manifests = true
  path               = "dev-cluster"
}
