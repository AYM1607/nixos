# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ghostty, ... }:
let
  hello-script = import ../../nixos-modules/shell-apps/hello.nix {inherit pkgs; };
  print-colors-script = import ../../nixos-modules/shell-apps/print-colors.nix { inherit pkgs; };
in
{
  imports = lib.flatten [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../common/core

      # Set up relative to root.
      ../common/optional/yubikey.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Firmware updates.
  services.fwupd.enable = true;
  # Support for the fingerprint reader.
  services.fprintd.enable = true;
  # bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  # power saving on amd laptops.
  services.power-profiles-daemon.enable = true;
  # Bonjour
  services.murmur.bonjour = true;
  
  # Allow using flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation.docker.enable = true;

  networking.hostName = "nixlap"; # Define your hostname.
  # TODO: Move the passwords to secrets before pushing this to source control.
  networking.wireless = { # Enables wireless supprto through wpa supplicant.
    enable = true;
    secretsFile = config.sops.secrets."wireless.env".path;
    networks = {
      # Home
      "UG_LivingRoom_5G" = {
        pskRaw = "ext:home_psk";
      };
      # Whidbey coffee.
      pioneer = {
        psk = "Coffee99";
      };
      "Tim Hortons WiFi" = {};
      # Mayne Island cabin
      "SHAW-8D81B0" = {
        psk = "2511530A6165";
      };
      # Coffee shops
      "Story Coffee" = {
        psk = "YOURSTORY";
      };
      "SoulfoodGuest" = {
        psk = "javajava123";
      };
      "Cedar And Salt 2.4" = {
        psk = "Coffeehouse";
      };
      "Starbucks WiFi" = {};
    };
  };

  # Set your time zone.
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

  # Display
  services.xserver = {
    enable = true;
    enableTearFree = true;
    synaptics = {
      scrollDelta = -75;
    };
    windowManager.awesome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  services.picom = {
    enable = true;
    vSync = true;
  };
  # Allow autorandr hot-plug.
  services.autorandr.enable = true;

  programs.zsh.enable = true;
  users.users.jmug = {
    isNormalUser = true;
    description = "Mariano Uvalle";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };
  users.users.root = {
    shell = pkgs.zsh;
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # iPhone USB tethering.
  services.usbmuxd.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    rpi-imager
    fzf
    ripgrep
    i3lock-fancy
    # Logitech mouse
    logiops
    # System
    power-profiles-daemon
    htop
    git
    neovim
    wget
    libnotify
    autorandr
    # iOS tethering and mounting
    libimobiledevice
    ifuse
    # Custom shell apps
    hello-script
    print-colors-script
    # Terminal
    ghostty.packages.x86_64-linux.default
    # Thin provisioning tools
    thin-provisioning-tools
  ];
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "BigBlueTerminal" ]; })
      fira-code-nerdfont
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
              invert: true;
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

  # Install keyd for system level key remapping.
  services.keyd = {
    enable = true;
    keyboards.colemakdhm = {
      ids = [ "0001:0001:70533846" ];
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
          leftalt = "leftmeta";
          leftmeta = "leftalt";
          capslock = "leftcontrol";
        };
      };
    };
  };
  
  services.acpid = {
    enable = true;
    # Run autorandr when the lid opens/closes.
    lidEventCommands = ''
    export PATH=/run/wrappers/bin:/run/current-system/sw/bin:$PATH
    export DISPLAY=":0.0"
    export XAUTHORITY="/home/jmug/.Xauthority"
    sudo -u jmug autorandr --change
    '';
  };

  # Bluetooth.
  services.blueman.enable = true;

  # USB devices
  services.devmon.enable = true;
  services.gvfs.enable = true; 
  services.udisks2.enable = true;

  # Smart Cards (required for yubico authenticator)
  services.pcscd.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
