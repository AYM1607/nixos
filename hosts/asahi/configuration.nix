# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config,
  lib,
  pkgs,
  apple-silicon,
  ghostty,
  ...
}:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      apple-silicon.nixosModules.apple-silicon-support
      # Sops and other stuff.
      ../common/core
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "asahi-nix"; # Define your hostname.
  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      "UG_LivingRoom_5G" = {
        pskRaw = "ext:home_psk";
      };
    };
  };

  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "overlay";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # This doesn't seem to be doing anything in hyprland because it configure libinput directly.
  # I'll leave it here just in case, but doesn't seem necessary.
  services.libinput = {
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };
  users.users.jmug = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      git
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.keyd = {
    enable = true;
    keyboards.colemakdhm = {
      ids = [ "05ac:0351:6f083222" ];
      settings = {
        main = {
          e = "f";
          r = "p";
          t = "b";
          y = "j";
          u = "l";
          i = "u";
          o = "y";
          p = ";";
          s = "r";
          d = "s";
          f = "t";
          h = "m";
          j = "n";
          k = "e";
          l = "i";
          ";" = "o";
          v = "d";
          b = "v";
          n = "k";
          m = "h";
          capslock = "leftcontrol";
        };
      };
    };
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    keyd
    kitty
    htop
    # Terminal
    ghostty.packages.aarch64-linux.default
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # This is not really enabling X11, bad naming.
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  # USB devices.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  system.stateVersion = "25.05"; # Don't change!!!
}
