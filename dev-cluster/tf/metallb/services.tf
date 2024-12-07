resource "kubernetes_service" "metallb_webhook_service" {
  metadata {
    name      = "metallb-webhook-service"
    namespace = "metallb-system"
  }

  spec {
    selector = {
      component = "controller"
    }

    port {
      port        = 443
      target_port = 9443
    }
  }
}
