{ pkgs, ... } :

{
  imports = [
    ../../home-modules/default.nix
    ../../home-modules/nvim.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/direnv.nix
    ../../home-modules/zsh.nix
    ../../home-modules/tmux.nix
  ];

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    stateVersion = "25.05";
  };

  programs.zsh = {
    shellAliases = {
      homesw = "home-manager --flake /home/jmug/nixos#devbox --extra-experimental-features nix-command --extra-experimental-features flakes switch";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
