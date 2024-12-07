provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://github.com/fxttr/k8s.git"
    branch = "master"
    
    http = {
      username = "fxttr"
      password = var.github_token
    }
  }
}

provider "github" {
  owner = "fxttr"
  token = var.github_token
}