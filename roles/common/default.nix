{ pkgs, ... }:

{
  # common settings
  networking.firewall.allowedTCPPorts = [ 8080 80 443 ];
  i18n.defaultLocale = "pl_PL.UTF-8";
  time.timeZone = "Europe/Warsaw";
  virtualisation.docker.enable = true;

  # IOHK binary cache
  nix.binaryCaches = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
  nix.binaryCachePublicKeys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
  ];

  # Enable nix experimental features
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # standard set of packages
  environment.systemPackages = with pkgs; [
    # cardano-node
    # FIXME Currently this derivation cannot compile. For full logs, run
    # 'nix log /nix/store/60k2wzy1ip1ls9flfsvfcsn4hhd0sm90-cardano-wallet-core-lib-cardano-wallet-core-2021.11.11.drv'.
    # on ec2 to investigate this
    # cardano-wallet

    byrun
    docker-compose
    git
    htop
    ripgrep
    tmux
    vim
    yarn

    nodePackages.node2nix
  ];

  # vim as a default editor
  environment.variables = { EDITOR = "vim"; };

  # nginx
  security.acme.acceptTerms = true;
  security.acme.email = "p.placzynski+byron@binarapps.com";
  users.users.nginx.extraGroups = [ "acme" ];

  security.acme.certs."test.byron.network" = {
    email = "p.placzynski+byron@binarapps.com";
    group = "nginx";
  };
  
  services.nginx = {
    enable = true;

    virtualHosts = {
      "test.byron.network" = {
        addSSL = true;
        enableACME = true;
        locations."/" = { proxyPass = "http://127.0.0.1:3000"; };
        locations."^~ /tokens-registry" = {
          extraConfig = ''
            rewrite ^/tokens-registry/(.*)''$ /''$1 break;
            proxy_pass http://localhost:9990/;
          '';
        };
      };
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
  };
}
