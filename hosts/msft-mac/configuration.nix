{ self, pkgs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neofetch
  ];

  system.primaryUser = "jmug";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };

    caskArgs = {
      no_quarantine = true;
    };

    taps = [];
    brews = [
    ];
    casks = [
      "ghostty"
      "secretive"
      "karabiner-elements"
      "raycast"
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.bigblue-terminal
  ];

  users.users.jmug.home = "/Users/jmug";

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
