# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config, lib, pkgs, ghostty, ... }:
let
  pubKeys = lib.filesystem.listFilesRecursive ../common/keys;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Sops and other stuff.
      ../common/core
      ../common/optional/yubikey.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  virtualisation.docker.enable = true;

  # Bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # WiFi
  networking.hostName = "nixbox"; # Define your hostname.
  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      "UG_LivingRoom_5G" = {
        pskRaw = "ext:home_psk";
      };
    };
  };

  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.zsh.enable = true;
  users.users.jmug = {
    isNormalUser = true;
    description = "Mariano Uvalle";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };
  users.users.root = {
    shell = pkgs.zsh;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
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
    ghostty.packages.x86_64-linux.default
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
  # home-manager.users.gdm = { lib, ... }: {
  #   home.stateVersion = "25.05"; # Do not change!!!
  #   dconf.settings = {
  #     "org/gnome/desktop/interface" = {
  #       scaling-factor = lib.hm.gvariant.mkUint32 2;
  #     };
  #   };
  # };

  # USB devices.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 69 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "25.05"; # Did you read the comment?
}
