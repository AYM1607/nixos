{ ... }: {
  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "emacs";
  };
}
