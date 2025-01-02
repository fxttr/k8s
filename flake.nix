{
  description = "Next-gen Datastack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    code-nix = {
      url = "github:fxttr/code-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        extensions.follows = "nix-vscode-extensions";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
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
        code = inputs.code-nix.packages.${system}.default;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            tofu
            pkgs.talosctl
            pkgs.k9s
            pkgs.nano
            pkgs.sops
            pkgs.kubectl
            pkgs.kubernetes-helm
            pkgs.fluxcd
            (code {
              profiles.nix.enable = true;
            })
          ];
        };
      });
}
