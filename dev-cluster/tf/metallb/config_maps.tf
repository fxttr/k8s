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

resource "kubernetes_config_map" "metallb_excludel2" {
  metadata {
    name      = "metallb-excludel2"
    namespace = "metallb-system"
  }

  data = {
    "excludel2.yaml" = <<EOT
    announcedInterfacesToExclude: ["^docker.*", "^cbr.*", "^dummy.*", "^virbr.*", "^lxcbr.*", "^veth.*", "^lo$", "^cali.*", "^tunl.*", "^flannel.*", "^kube-ipvs.*", "^cni.*", "^nodelocaldns.*"]
    EOT
  }
}