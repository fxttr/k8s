# Create Namespace
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"

    labels = {
      app = "vault"
    }
  }
}