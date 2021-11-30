{
  description = "Dex NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cardano-node.url = "github:input-output-hk/cardano-node";
  };

  outputs = { self, nixpkgs, flake-utils, cardano-node, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [
            (import ./packages)
          ];
        };
      in
      {
        nixosConfigurations = {
          ec2-backend-byron-network = nixpkgs.lib.nixosSystem {
            inherit pkgs system;
            modules = [
              ./hosts # main configuration file for hosts
              ./roles/common # common configuration for any instance
              ./users/dex # `dex` user setup
            ];
          };
        };
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ rnix-lsp ];
        };
      });
}
