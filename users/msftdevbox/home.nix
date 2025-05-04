{ pkgs, pkgs-msft-go, pkgs-unstable, ... } :

{
  imports = [
    ../../home-modules/default.nix
    ../../home-modules/nvim.nix
    ../../home-modules/tmux.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/direnv.nix
    ../../home-modules/zsh.nix
  ];

  home = {
    username = "juva";
    homeDirectory = "/home/juva";

    packages = with pkgs; [
      pkgs-msft-go.go_1_23
      pkgs-msft-go.gopls
      pkgs-msft-go.gotools
      pkgs-msft-go.mockgen
      pkgs-unstable.kubernetes-controller-tools
      jq
      yq
      kind
      kubernetes-helm
      fzf
      ripgrep
    ];   

    stateVersion = "24.11";
  };

  programs.zsh = {
    shellAliases = {
      homesw = "home-manager --flake /home/juva/nixos#msftdevbox --extra-experimental-features nix-command --extra-experimental-features flakes switch";
      adev = "/home/juva/dev/aks-rp/bin/aksdev";
      ksc = "KUBECONFIG=/home/juva/Downloads/cxkubeconfig.yaml kubectl";
      kso = "KUBECONFIG=/home/juva/Downloads/overlaykubeconfig.yaml kubectl";
      k = "kubectl";
    };
    initExtra = ''
    export GONOPROXY='github.com,golang.org,googlesource.com,opentelemetry.io,uber.org'
    export GOPRIVATE='goms.io,*.goms.io'
    export GOPROXY='https://goproxyprod.goms.io'
    export PATH=$PATH:$HOME/bin
    '';
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
