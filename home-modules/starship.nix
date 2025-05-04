{ ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      username.format = "[$user](213) ";
      hostname = {
        disabled = false;
        ssh_symbol = "🌐";
        style = "bold green";
      };
      nix_shell = {
        format = "[$symbol$state nix-shell]($style) ";
        symbol = "❄️ ";
        pure_msg = "p";
        impure_msg = "i";
      };
      golang = {
        format = "go [$symbol $version ]($style)";
        symbol = "🦫";
      };
      character = {
        error_symbol = "[✖](bold red)";
      };
      directory = {
        truncation_symbol = ".../";
      };
    };
  };
}
