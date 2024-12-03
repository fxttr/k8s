# Create Config Watcher Role
resource "kubernetes_role" "config_watcher" {
  metadata {
    labels = {
      app = "metallb"
    }
    name      = "config-watcher"
    namespace = kubernetes_namespace.metallb_system.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create Pod Lister Role
resource "kubernetes_role" "pod_lister" {
  metadata {
    labels = {
      app = "metallb"
    }
    name      = "pod-lister"
    namespace = kubernetes_namespace.metallb_system.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list"]
  }
}

resource "kubernetes_role" "controller" {
  metadata {
    labels = {
      app = "metallb"
    }
    name      = "controller"
    namespace = kubernetes_namespace.metallb_system.metadata.0.name
  }


  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups     = [""]
    resource_names = ["memberlist"]
    resources      = ["secrets"]
    verbs          = ["list"]
  }

  rule {
    api_groups     = ["apps"]
    resource_names = ["controller"]
    resources      = ["deployments"]
    verbs          = ["get"]
  }

  rule {
    api_groups = ["metallb.io"]
    resources  = ["bgppeers"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["metallb.io"]
    resources  = ["bfdprofiles"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metallb.io"]
    resources  = ["ipaddresspools"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metallb.io"]
    resources  = ["bgpadvertisements"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metallb.io"]
    resources  = ["l2advertisements"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metallb.io"]
    resources  = ["communities"]
    verbs      = ["get", "list", "watch"]
  }
}