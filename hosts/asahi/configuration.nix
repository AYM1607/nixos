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
      ../common/optional/yubikey.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "asahi-nix"; # Define your hostname.
  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      "UG_LivingRoom_5G" = {
        pskRaw = "ext:home_psk";
      };
      "pioneer" = {
        pskRaw = "ext:woods_pioneer_psk";
      };
      "Woods WiFi" = {};
      # Midway Laundry
      "NETGEARFDD76C-3" = {};
    };
  };

  hardware.asahi = {
    enable = true;
    setupAsahiSound = true;
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "overlay";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # This doesn't seem to be doing anything in hyprland because it configure libinput directly.
  # I'll leave it here just in case, but doesn't seem necessary.
  services.libinput = {
    enable = true;
  };

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

  environment.systemPackages = with pkgs; [
    keyd
    htop
    # Misc utils
    ripgrep
    fzf
    unzip
    nautilus
    # Terminal
    ghostty.packages.aarch64-linux.default
    kitty
    # Theming
    palenight-theme
    # Lock screen
    hyprlock
    # Idling
    sway-audio-idle-inhibit
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
      nerd-fonts.caskaydia-cove
    ];
  };

  security.pam.services.hyprlock = {};
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    # Enable wayland support for chromium/electron apps.
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    # This caused issues with walker, but might be some other
    # issue with wayland/hyprland, so will leave it here for now.
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # This is not really enabling X11, bad naming.
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
  # This is used to scale the gdm login screen,
  # try to set it up for fractional scaling in 
  # the future.
  home-manager.users.gdm = { lib, ... }: {
    home.stateVersion = "25.05"; # Do not change!!!
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        scaling-factor = lib.hm.gvariant.mkUint32 2;
      };
    };
  };

  # USB devices.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  system.stateVersion = "25.05"; # Don't change!!!
}
