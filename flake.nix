{
  description = "Dex NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    iohkNix.url = "github:input-output-hk/iohk-nix";
    cardano-node.url = "github:input-output-hk/cardano-node";
  };

  outputs = { self, nixpkgs, iohkNix, cardano-node, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          cardano-node.overlay
          iohkNix.overlays.haskell-nix-extra
          iohkNix.overlays.crypto
          iohkNix.overlays.cardano-lib
          iohkNix.overlays.utils
          (import ./packages) ];
      };
    in {
      nixosConfigurations = {
        ec2-backend-byron-network = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [
            ./hosts # main configuration file for hosts
            ./roles/common # common configuration for any instance
            ./roles/services # services services configuration
            ./users/dex # `dex` user setup
          ];
        };
      };
    };
}
