# Create Controller Cluster Role
resource "kubernetes_cluster_role" "controller" {
  metadata {
    labels = {
      app = "metallb"
    }
    name = "metallb-system:controller"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list"]
  }

  rule {
    api_groups = [""]
    resources  = ["services/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups       = ["policy"]
    resource_names   = ["controller"]
    resources        = ["podsecuritypolicies"]
    verbs            = ["use"]
  }

  rule {
    api_groups       = ["admissionregistration.k8s.io"]
    resource_names   = ["metallb-webhook-configuration"]
    resources        = ["validatingwebhookconfigurations"]
    verbs            = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups       = ["apiextensions.k8s.io"]
    resource_names   = [
      "bfdprofiles.metallb.io",
      "bgpadvertisements.metallb.io",
      "bgppeers.metallb.io",
      "ipaddresspools.metallb.io",
      "l2advertisements.metallb.io",
      "communities.metallb.io"
    ]
    resources        = ["customresourcedefinitions"]
    verbs            = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role" "speaker" {
  metadata {
    labels = {
      app = "metallb"
    }
    name = "metallb-system:speaker"
  }

  rule {
    api_groups = ["metallb.io"]
    resources = [ "servicel2statuses", "servicel2statuses/status" ]
    verbs = [ "*" ]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "nodes", "namespaces"]
    verbs      = ["get", "list", "watch"]

  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]

  }

  rule {
    api_groups     = ["policy"]
    resource_names = ["speaker"]
    resources      = ["podsecuritypolicies"]
    verbs          = ["use"]

  }
}