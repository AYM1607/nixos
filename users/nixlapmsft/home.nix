{ config, lib, nixgl, pkgs, pkgs-msft-go, pkgs-unstable, ghostty, ... } :

{
  imports = [
    ../../home-modules/default.nix
    ../../home-modules/nvim.nix
    ../../home-modules/tmux.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/direnv.nix
    ../../home-modules/zsh.nix
    ../../home-modules/ghostty-mac-config.nix
  ];

  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  # Effort to make applications show up in Gnome's "show applications"
  targets.genericLinux.enable = true;
  programs.bash.enable = true;

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    packages = with pkgs; [
      pkgs-msft-go.go_1_23
      pkgs-msft-go.gopls
      pkgs-msft-go.gotools
      pkgs-msft-go.mockgen
      pkgs-unstable.kubernetes-controller-tools
      azure-cli
      kubectl
      jq
      yq
      kind
      kubernetes-helm
      fzf
      ripgrep
      (config.lib.nixGL.wrap ghostty.packages.x86_64-linux.default)
      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
    ];   

    stateVersion = "24.11";
  };

  programs.zsh = {
    shellAliases = {
      homesw = "home-manager --flake /home/jmug/nixos#nixlapmsft --extra-experimental-features nix-command --extra-experimental-features flakes switch";
      radev = "/home/jmug/dev/aks-rp/bin/aksdev";
      ksc = "KUBECONFIG=/home/jmug/Downloads/cxkubeconfig.yaml kubectl";
      kso = "KUBECONFIG=/home/jmug/Downloads/overlaykubeconfig.yaml kubectl";
      k = "kubectl";
    };
    initExtra = ''
    export GONOPROXY='github.com,golang.org,googlesource.com,opentelemetry.io,uber.org'
    export GOPRIVATE='goms.io,*.goms.io'
    export GOPROXY='https://goproxyprod.goms.io'
    export PATH=$PATH:$HOME/bin
    export PATH=$PATH:$HOME/go/bin
    '';
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
