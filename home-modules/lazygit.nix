{ ... }: {
  programs.lazygit = {
    enable = true;
    settings = {
      # git.commit.signOff = true;
      git.autoFetch = false;
      git.autoRefresh = false;
      keybinding = {
        universal = {
          prevItem-alt = "e";
          nextItem-alt = "n";
          prevBlock-alt = "m";
          nextBlock-alt = "i";
          nextMatch = "@";
          prevMatch = "#";
          new = "+";
          edit = "~";
          nextScreenMode = "*";
        };
        files.ignoreFile = "-";
        branches.viewGitFlowOptions = "g";
        commits.startInteractiveRebase = "I";
        submodules.init = "I";
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      lg = "lazygit";
    };
  };
}
