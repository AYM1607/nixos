{ pkgs, ... } : {
  
  home.packages = with pkgs; [
      neovim
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
}
