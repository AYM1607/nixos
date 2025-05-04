{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      lua-language-server
      neovim
      zip
      unzip
      eza
    ];
  };

  programs.zsh = {
    shellAliases = {
      ls = "eza";
      n = "nvim";
    };
  };
}
