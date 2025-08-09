{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      fzf
      ripgrep
      zip
      unzip
      eza
      wget
    ];
  };

  programs.zsh = {
    shellAliases = {
      ls = "eza";
    };
  };
}
