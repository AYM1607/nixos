{ config, lib, pkgs, ... }:

with lib;

{
  options.nvim = {
    enable = mkEnableOption "Enable custom neovim configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.neovim;
      description = "The neovim package to use";
    };
  };

  config = mkIf config.nvim.enable {
    home.packages = [
      pkgs.lua-language-server
      config.nvim.package
    ];

    programs.zsh = {
      shellAliases = {
        n = "nvim";
      };
    };

    home.file.".config/nvim" = {
      recursive = true;
      source = ./explicit-configs/nvim;
    };
  };
}
