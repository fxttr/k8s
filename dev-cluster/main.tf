module "metallb" {
  source = "./metallb"
  metallb_version = "0.14.8"
}

module "vault" {
  source = "./vault"
}

module "flux-cesium" {
  source = "./flux"
  github_org = "fxttr"
  github_repository = "cesium"
  github_token = var.github_token
}