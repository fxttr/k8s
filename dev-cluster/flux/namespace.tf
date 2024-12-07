resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}