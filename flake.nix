{
  description = "Dex NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    cardano-node.url = "github:input-output-hk/cardano-node";
  };

  outputs =
    { nixpkgs
    , cardano-node
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (import ./packages)
        ];
      };
    in
    {
      # devShell.${system} = import ./shell.nix { inherit pkgs; };
      nixosConfigurations = {
        ec2-backend-byron-network = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [
            ./hosts             # main configuration file for hosts
            ./roles/common      # common configuration for any instance
            ./users/dex         # `dex` user setup
          ];
        };
      };
    };
}
