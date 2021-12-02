{
  description = "Dex NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    iohkNix.url = "github:input-output-hk/iohk-nix";
    cardano-node.url = "github:input-output-hk/cardano-node";
    cardano-wallet.url = "github:input-output-hk/cardano-wallet/flake";
  };

  outputs = { self, nixpkgs, flake-utils, iohkNix, cardano-node, cardano-wallet, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          cardano-node.overlay
          cardano-wallet.overlay
          iohkNix.overlays.haskell-nix-extra
          iohkNix.overlays.crypto
          iohkNix.overlays.cardano-lib
          iohkNix.overlays.utils
          (final: prev: {
            commonLib = nixpkgs.lib
            // iohkNix.lib
            // final.cardanoLib;
          })
          (import ./packages) ];
      };
    in {
      nixosConfigurations = {
        ec2-backend-byron-network = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [
            cardano-node.nixosModules.cardano-node
            ./hosts # main configuration file for hosts
            ./roles/common # common configuration for any instance
            ./roles/services # services services configuration
            ./users/dex # `dex` user setup
          ];
        };
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in {
        devShell = pkgs.mkShell {
          packages = with pkgs; [ rnix-lsp ];
        };
      });
}
