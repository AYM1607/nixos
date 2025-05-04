{ pkgs, ... } : {

  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    userName = "jmug";
    userEmail = "u.g.a.mariano@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
