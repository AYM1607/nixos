{ ... } : {
  programs.walker = {
    enable = true;

    config = {
      ui.fullscreen = true;
      list = {
        height = 200;
      };
      websearch.prefix = "?";
    };
  };
}
