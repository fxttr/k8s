{
  description = "Next-gen Datastack";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system: let 
      pkgs = import nixpkgs { inherit system; }; 
    in 
    {
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.k9s
          pkgs.opentofu
          pkgs.nano
          pkgs.sops
        ];

        shellHook = ''
          function tofu {
            sops --decrypt terraform.enc.tfstate > terraform.tfstate
            tofu $@
            sops --encrypt terraform.tfstate > terraform.enc.tfstate
          }
        '';
      };
    });
}
