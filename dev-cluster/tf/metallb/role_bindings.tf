resource "kubernetes_role_binding" "controller" {
  metadata {
    name      = "controller"
    namespace = "metallb-system"
    labels = {
      app = "metallb"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "controller"
    namespace = "metallb-system"
  }
}

resource "kubernetes_role_binding" "pod_lister" {
  metadata {
    name      = "pod-lister"
    namespace = "metallb-system"
    labels = {
      app = "metallb"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "pod-lister"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "speaker"
    namespace = "metallb-system"
  }
}
