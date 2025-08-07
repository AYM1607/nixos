{ ... } : {
  programs.zsh.profileExtra = ''
  eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
