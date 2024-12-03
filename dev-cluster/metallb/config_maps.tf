resource "kubernetes_config_map" "metallb_config" {
  metadata {
    name      = "config"
    namespace = "metallb-system"
  }

  data = {
    "config" = <<EOF
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - "192.168.1.210-192.168.1.250"
    EOF
  }
}
