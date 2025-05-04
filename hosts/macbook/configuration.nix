{ self, pkgs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neofetch
  ];

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
      "raylib"
    ];
    casks = [
      "ghostty"
      "kicad"
      "secretive"
      "gcc-arm-embedded"
      "librewolf"
    ];
  };

  fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "BigBlueTerminal" ]; })
  ];

  users.users.uagm.home = "/Users/uagm";

  nixpkgs.config.allowUnfree = true;
  
  programs.zsh.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
