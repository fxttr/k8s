resource "kubernetes_daemonset" "metallb_speaker" {
  metadata {
    name      = "speaker"
    namespace = "metallb-system"
    labels = {
      app       = "metallb"
      component = "speaker"
    }
  }

  spec {
    selector {
      match_labels = {
        app       = "metallb"
        component = "speaker"
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
          component = "speaker"
        }
      }

      spec {

        automount_service_account_token  = true # override Terraform's default false - https://github.com/kubernetes/kubernetes/issues/27973#issuecomment-462185284
        service_account_name             = "speaker"
        termination_grace_period_seconds = 2
        host_network                     = true
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          name  = "speaker"
          image = "quay.io/metallb/speaker:v${var.metallb_version}"

          args = [
            "--port=7472",
            "--log-level=info"
          ]

          env {
            name = "METALLB_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "METALLB_POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "METALLB_HOST"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }

          env {
            name = "METALLB_ML_BIND_ADDR"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name  = "METALLB_ML_LABELS"
            value = "app=metallb,component=speaker"
          }

          env {
            name  = "METALLB_ML_SECRET_KEY_PATH"
            value = "/etc/ml_secret_key"
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
              add  = ["NET_RAW"]
              drop = ["ALL"]
            }
            read_only_root_filesystem = true
          }

          volume_mount {
            name       = "memberlist"
            mount_path = "/etc/ml_secret_key"
            read_only  = true
          }

          volume_mount {
            name       = "metallb-excludel2"
            mount_path = "/etc/metallb"
            read_only  = true
          }

          port {
            container_port = 7472
            name           = "monitoring"
          }

          port {
            container_port = 7946
            name           = "memberlist-tcp"
          }

          port {
            container_port = 7946
            name           = "memberlist-udp"
            protocol       = "UDP"
          }
        }

        volume {
          name = "memberlist"
          secret {
            secret_name = "memberlist"
            default_mode = "0420"
          }
        }

        volume {
          name = "metallb-excludel2"
          config_map {
            name         = "metallb-excludel2"
            default_mode = "0400"
          }
        }
      }
    }
  }
}
