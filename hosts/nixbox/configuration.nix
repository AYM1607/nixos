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
  nixpkgs.config.allowUnfree = true;  
  virtualisation.docker.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.hostName = "nixos"; # Define your hostname.
  networking.hostName = "nixbox";
  networking.wireless = {
    enable = true;
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      "UG_LivingRoom_5G" = {
        pskRaw = "ext:home_psk";
      };
    };
  };
  # Configure network connections interactively with nmcli or nmtui.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
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
  user.name = "jmug";
  users.users.jmug = {
    isNormalUser = true;
    description = "Mariano Uvalle";
    extraGroups = [ "wheel" "docker"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
      btop
      git
    ];
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };
  users.users.root = {
    shell = pkgs.zsh;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    chromium
    # Misc utils
    ripgrep
    fzf
    unzip
    nautilus
    keyd
    # Terminal
    ghostty.packages.x86_64-linux.default
    kitty
    # Theming
    palenight-theme
    # Lock screen
    hyprlock
    # Idling
    sway-audio-idle-inhibit
    logiops
    # networking.
    tailscale
    tailscale-systray
  ];
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
      nerd-fonts.caskaydia-cove
    ];
  };

  # Logiops daemon
  systemd.packages = [ pkgs.logiops ];
  systemd.services.logid.wantedBy = [ "multi-user.target" ];
  environment.etc = {
    "logid.cfg" = {
      # For some reason scroll inversion does not work for the mx vertical...
      text = ''
        devices: (
          {
            name: "Wireless Mouse MX Master 3";

            hiresscroll: {
            };

            thumbwheel: {
              invert: true;
            };

            buttons: (
                  {
                      cid: 0x53;
                      action =
                      {
                          type :  "Keypress";
                          keys: ["KEY_LEFTMETA", "KEY_LEFT"];
                      };
                  },
                  {
                      cid: 0x56;
                      action =
                      {
                          type :  "Keypress";
                          keys: ["KEY_LEFTMETA", "KEY_RIGHT"];
                      };
                  }
              );
          },
          {
            name: "MX Vertical Advanced Ergonomic Mouse";

            hiresscroll: {
              hires: true;
              invert: false;
              target: false;
            };

            buttons: (
                  {
                      cid: 0x53;
                      action =
                      {
                          type :  "Keypress";
                          keys: ["KEY_LEFTMETA", "KEY_PAGEUP"];
                      };
                  },
                  {
                      cid: 0x56;
                      action =
                      {
                          type :  "Keypress";
                          keys: ["KEY_LEFTMETA", "KEY_PAGEDOWN"];
                      };
                  },
                  {
                      cid: 0xfd;
                      action =
                      {
                          type : "Keypress";
                          keys: ["KEY_LEFTMETA"];
                      };
                  }
           );
          }
        );
      '';
    };
  };

  services.keyd = {
    enable = true;
    keyboards.colemakdhm = {
      ids = [ "320f:5088:37b39d24" ];
      settings = {
        main = {
          capslock = "leftcontrol";
          leftcontrol = "capslock";
        };
      };
    };
  };

  services.tailscale.enable = true;

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
  services.xserver.enable = true;
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # USB devices.
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable the OpenSSH daemon.
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # ports = [ 69 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Enable firewall and only allw some ports.
  networking.firewall.enable = false;

  system.stateVersion = "25.11"; # Did you read the comment?
}

