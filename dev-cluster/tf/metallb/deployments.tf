resource "kubernetes_deployment" "metallb_controller" {
  metadata {
    name      = "controller"
    namespace = kubernetes_namespace.metallb_system.metadata.0.name
    labels = {
      app       = "metallb"
      component = "controller"
    }
  }

  spec {
    revision_history_limit = 3

    selector {
      match_labels = {
        app       = "metallb"
        component = "controller"
      }
    }

    template {
      metadata {
        annotations = {
          "prometheus.io/port"   = "7472"
          "prometheus.io/scrape" = "true"
        }
        labels = {
          app       = "metallb"
          component = "controller"
        }
      }

      spec {
        automount_service_account_token  = true
        service_account_name          = "controller"
        termination_grace_period_seconds = 0

        security_context {
          fs_group      = 65534
          run_as_non_root = true
          run_as_user   = 65534
        }

        node_selector = merge(
          { "kubernetes.io/os" = "linux" },
          var.controller_node_selector
        )

        container {
          name  = "controller"
          image = "quay.io/metallb/controller:v${var.metallb_version}"

          args = [
            "--port=7472",
            "--log-level=info",
            "--tls-min-version=VersionTLS12"
          ]

          env {
            name  = "METALLB_ML_SECRET_NAME"
            value = "memberlist"
          }

          env {
            name  = "METALLB_DEPLOYMENT"
            value = "controller"
          }

          liveness_probe {
            http_get {
              path = "/metrics"
              port = "monitoring"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
            timeout_seconds       = 1
          }

          readiness_probe {
            http_get {
              path = "/metrics"
              port = "monitoring"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
            timeout_seconds       = 1
          }

          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            read_only_root_filesystem = true
          }

          port {
            container_port = 7472
            name           = "monitoring"
          }

          port {
            container_port = 9443
            name           = "webhook-server"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "cert"
            mount_path = "/tmp/k8s-webhook-server/serving-certs"
            read_only  = true
          }
        }

        dynamic "toleration" {
          for_each = var.controller_toleration
          content {
            key                = toleration.value["key"]
            effect             = toleration.value["effect"]
            operator           = lookup(toleration.value, "operator", null)
            value              = lookup(toleration.value, "value", null)
            toleration_seconds = lookup(toleration.value, "toleration_seconds", null)
          }
        }

        volume {
          name = "cert"
          secret {
            secret_name = "metallb-webhook-cert"
            default_mode = "0420"
          }
        }
      }
    }
  }
}
