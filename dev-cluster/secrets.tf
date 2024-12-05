data "sops_file" "sops-secret" {
    source_file = "secrets/dev-cluster.yaml"
}