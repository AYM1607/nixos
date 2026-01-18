{ pkgs, ... } : {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        match-mode = "fzf";
        exit-on-keyboard-focus-loss = "yes";
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        selection = "45475add";
      };
    };
  };
}
