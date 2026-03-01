{ pkgs, ... } : {

  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "jmug";
        email = "u.g.a.mariano@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}
