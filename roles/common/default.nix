{ pkgs, ... }:

{
  # common settings
  networking.firewall.allowedTCPPorts = [ 8080 ];
  i18n.defaultLocale           = "pl_PL.UTF-8";
  time.timeZone                = "Europe/Warsaw";
  virtualisation.docker.enable = true;

  # IOHK binary cache
  nix.binaryCaches = [
    "https://hydra.iohk.io"
    "https://iohk.cachix.org"
  ];
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
    cardano-node
    byrun
    docker-compose
    git
    htop
    tmux
    vim
  ];

  # vim as a default editor
  environment.variables = {
    EDITOR = "vim";
  };
}
