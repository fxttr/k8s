resource "kubernetes_secret" "metallb_webhook_cert" {
  metadata {
    name      = "metallb-webhook-cert"
    namespace = "metallb-system"
  }
}