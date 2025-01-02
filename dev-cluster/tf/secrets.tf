data "sops_file" "sops-secret" {
    source_file = "dev-cluster/tf/secrets/cluster.yaml"
}