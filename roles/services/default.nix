{ pkgs, lib, config, ... }: {

  # TODO cardano-wallet-service.nix could be found within cardano-wallet flake repository here:
  # https://github.com/input-output-hk/cardano-wallet/blob/flake/nix/nixos/cardano-wallet-service.nix

  services.cardano-node = {
    enable = true;
    systemdSocketActivation = true;
    port = 3001;
    hostAddr = "127.0.0.1";
    environment = "testnet";
    topology = ./config/testnet-topology.json;
    cardanoNodePkgs = pkgs;
    nodeConfig =
      config.services.cardano-node.environments.${config.services.cardano-node.environment}.nodeConfig
      // {
        hasPrometheus = [ config.services.cardano-node.hostAddr 12798 ];
        # Use Journald output:
        setupScribes = [{
          scKind = "JournalSK";
          scName = "cardano";
          scFormat = "ScText";
        }];
        defaultScribes = [[ "JournalSK" "cardano" ]];
      };
  };
  systemd.services.cardano-node.serviceConfig.Restart = lib.mkForce "no";

  services.cardano-wallet = # let cfg = config.services.cardano-wallet;
    {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 8090;
      nodeSocket = "/run/cardano-node/node.socket";
      # project = lib.mkDefault project;
      walletMode = "testnet";

      # environment = lib.mkDefault envConfig.name;
      # database = lib.mkDefault "./db-cardano-wallet-${cfg.environment}";
    };

}
