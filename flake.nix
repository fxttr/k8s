{
  description = "Next-gen Datastack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        tofu = pkgs.writeShellScriptBin "tofu" ''
          #!/usr/bin/env bash
          if [ -f terraform.enc.tfstate ]; then
            sops --decrypt terraform.enc.tfstate > terraform.tfstate
          fi

          if [ -f terraform.enc.tfstate.backup ]; then
            sops --decrypt terraform.enc.tfstate.backup > terraform.tfstate.backup
          fi
          
          ${pkgs.opentofu}/bin/tofu "$@"

          if [ '$@' != "plan" ]; then
            sops --encrypt terraform.tfstate > terraform.enc.tfstate
            sops --encrypt terraform.tfstate.backup > terraform.enc.tfstate.backup
          fi
          
          rm -f terraform.tfstate terraform.tfstate.backup
        '';
        talosctl = pkgs.writeShellScriptBin "talosctl" ''
          #!/usr/bin/env bash
          talosctl "$@" -n 192.168.0.201 --talosconfig=./talos/controlplane.yaml
        '';
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            tofu
            talosctl
            pkgs.k9s
            pkgs.nano
            pkgs.sops
            pkgs.kubectl
            pkgs.kubernetes-helm
            pkgs.fluxcd
          ];
        };
      });
}
