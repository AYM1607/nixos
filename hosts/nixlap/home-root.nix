
{ config, pkgs, ... } :

{

  imports = [
    ../../home-modules/default.nix
    ../../home-modules/nvim.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/zsh.nix
  ];

  home = {
    username = "root";
    homeDirectory = "/root";

    stateVersion = "24.11";
  };

  programs.zsh = {
    shellAliases = {
      lg = "lazygit";
      n = "nvim";
      # TODO: Interpolate the hostname here.
      nrsw = "nixos-rebuild switch --flake /home/jmug/nixos#nixlap";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
