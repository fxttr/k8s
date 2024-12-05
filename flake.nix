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
          set -euo pipefail

          if [ -f terraform.enc.tfstate ]; then
            sops --decrypt terraform.enc.tfstate > terraform.tfstate
          fi

          if [ -f terraform.enc.tfstate.backup ]; then
            sops --decrypt terraform.enc.tfstate.backup > terraform.tfstate.backup
          fi
          
          ${pkgs.opentofu}/bin/tofu "$@"

          sops --encrypt terraform.tfstate > terraform.enc.tfstate
          sops --encrypt terraform.tfstate.backup > terraform.enc.tfstate.backup

          rm -f terraform.tfstate terraform.tfstate.backup
        '';
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            tofu
            pkgs.k9s
            pkgs.nano
            pkgs.sops
          ];
        };
      });
}
