{ pkgs, lib, config, ... }:
let commonLib = with pkgs; lib // cardanoLib;
in {
  imports = [ ./cardano-node-service.nix ];
  services.cardano-node = {
    enable = true;
    systemdSocketActivation = true;
    port = 3001;
    hostAddr = "127.0.0.1";
    environment = "testnet";
    topology = commonLib.mkEdgeTopology {
      port = 3001;
      edgeNodes = [ "127.0.0.1" ];
    };
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
}
