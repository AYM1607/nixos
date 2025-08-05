{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      fzf
      ripgrep
      zip
      unzip
      eza
    ];
  };

  programs.zsh = {
    shellAliases = {
      ls = "eza";
    };
  };
}
