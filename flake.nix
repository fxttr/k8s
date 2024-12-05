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

          if [ ! -f terraform.enc.tfstate ]; then
            ${pkgs.opentofu}/bin/tofu "$@"
            sops --encrypt terraform.tfstate > terraform.enc.tfstate
            exit 1
          fi

          sops --decrypt terraform.enc.tfstate > terraform.tfstate
          ${pkgs.opentofu}/bin/tofu "$@"
          sops --encrypt terraform.tfstate > terraform.enc.tfstate
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
