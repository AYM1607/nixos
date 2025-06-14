{ config, pkgs, ... } : {
  
  imports = [
    ../../home-modules/tmux-darwin.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/zsh.nix
    ../../home-modules/starship.nix
    ../../home-modules/nvim.nix
    ../../home-modules/direnv.nix
    # I should update the module with an option for adding winodow decorations.
    ../../home-modules/ghostty-mac-config.nix
  ];

  home = {
    username = "uagm";
    homeDirectory = "/Users/uagm";

    packages = with pkgs; [
      fzf
      ripgrep
      exercism
      typescript-language-server
      lua-language-server
      starship
      audacity
    ];

    stateVersion = "24.11";
  };

  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      flakeconf = "nvim /Users/uagm/nixos/flake.nix";
      sysconf = "nvim /Users/uagm/nixos/hosts/macbook/configuration.nix";
      homeconf = "nvim /Users/uagm/nixos/hosts/macbook/home.nix";
      nvconf = "nvim /Users/uagm/nixos/home-modules/explicit-configs/nvim/init.lua";
      # TODO: Interpolate the name of the host here.
      nrsw = "sudo darwin-rebuild switch --flake /Users/uagm/nixos#macbook";
    };
  };
}
