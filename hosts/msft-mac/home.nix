{
  config,
  pkgs,
  pkgs-unstable,
  user,
  ...
} :
let
  username = user.name;
  homeDirectory = user.homeDirectory;
in {

  imports = [
    ../../home-modules/default.nix
    ../../home-modules/direnv.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/homebrew.nix
    ../../home-modules/karabiner.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/nvim.nix
    ../../home-modules/secretive.nix
    ../../home-modules/starship.nix
    ../../home-modules/tmux.nix
    ../../home-modules/zsh.nix
  ];

  ghostty = {
    font-size = "17.2";
    window-decoration = true;
  };

  nvim = {
    enable = true;
    package = pkgs-unstable.neovim;
  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      jq
      yq
      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
      azure-cli

      go
      gopls
      gotools
      mockgen
      pkgs-unstable.kubernetes-controller-tools
      pkgs-unstable.kubectl
      pkgs-unstable.kubectl-node-shell
      pkgs-unstable.kind
      pkgs-unstable.kubernetes-helm

      pkgs-unstable.claude-code
      (pkgs-unstable.litellm.overrideAttrs (oldAttrs: rec {
        version = "1.74.9";
        src = pkgs.fetchFromGitHub {
          owner = "BerriAI";
          repo = "litellm";
          tag = "v${version}-stable";
          hash = "sha256-SGZwt2jzAQbOMlvudqPWat281su6OwT7JG2CNSMjL3A=";
        };
      }))
    ];

    stateVersion = "25.05";
  };


  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      flakeconf = "nvim ${homeDirectory}/nixos/flake.nix";
      sysconf = "nvim ${homeDirectory}/nixos/hosts/macbook/configuration.nix";
      homeconf = "nvim ${homeDirectory}/nixos/hosts/macbook/home.nix";
      nvconf = "nvim ${homeDirectory}/nixos/home-modules/explicit-configs/nvim/init.lua";
      # TODO: Interpolate the name of the host here.
      rshellconf="source ${homeDirectory}/.zshrc";
      radev = "${homeDirectory}/dev/aks-rp/bin/aksdev";
      ksc = "KUBECONFIG=${homeDirectory}/Downloads/cxkubeconfig.yaml kubectl";
      kso = "KUBECONFIG=${homeDirectory}/Downloads/overlaykubeconfig.yaml kubectl";
      k = "kubectl";
      nrsw = "sudo darwin-rebuild switch --flake ${homeDirectory}/nixos#msft-mac";
    };
    initExtra = ''
    export GONOPROXY='github.com,golang.org,googlesource.com,opentelemetry.io,uber.org'
    export GOPRIVATE='goms.io,*.goms.io'
    export GOPROXY='https://goproxyprod.goms.io'
    export PATH=$PATH:$HOME/bin
    export PATH=$PATH:$HOME/go/bin
    export PATH=$PATH:$HOME/.opencode/bin
    export __AKS_DOCKER_BUILD_MOUNT_NETRC=1
    '';
  };
}
