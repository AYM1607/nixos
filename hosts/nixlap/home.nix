{ lib, config, pkgs, ... } :
let
  pathToKeys = ../common/keys/yubi;
  yubiKeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathToKeys))
    (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key); # Remove .pub suffix.
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
      (key: { ".ssh/${key}.pub".source = "${pathToKeys}/${key}.pub"; })
      yubiKeys
  );
in
{

  imports = [
    ../../home-modules/default.nix
    ../../home-modules/nvim.nix
    ../../home-modules/tmux.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/direnv.nix
    ../../home-modules/zsh.nix
    ../../home-modules/vscode.nix
    ../../home-modules/books.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/sops.nix
  ];

  # Let home manager start the X11 session.
  xsession = {
    enable = true;
    windowManager.awesome.enable = true;
    initExtra = "
    albert &
    flameshot &
    ";
  };

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    packages = with pkgs; [
      gpick
      ticktick
      galculator
      blueman
      albert
      xclip
      fprintd
      keyd
      librewolf
      zig
      xorg.xwininfo
      neofetch
      # For battery widged.
      acpid
      # Screen management
      brightnessctl
      # Audio
      spotify
      spotify-tray
      # Communication
      discord
      slack
      # Wallpapers
      nitrogen
      # Coms
      whatsie
      discord
      # Embedded
      usbutils
      # Screenshots
      flameshot
      # xdg-open
      xdg-utils
      powertop
      age
      sops
      screen
    ];

    file = {
      ".config/awesome" = {
        recursive = true;
        source = ../../home-modules/explicit-configs/awesome;
      };
    } // yubikeyPublicKeyEntries; # Move yubikey stuff to a separate module.


    stateVersion = "24.11";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Posy_Cursor_Black";
    package = pkgs."posy-cursors";
  };

  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      flakeconf = "nvim /home/jmug/nixos/flake.nix";
      nosconf = "nvim /home/jmug/nixos/hosts/nixlap/configuration.nix";
      homeconf = "nvim /home/jmug/nixos/hosts/nixlap/home.nix";
      nvconf = "nvim /home/jmug/nixos/home-modules/explicit-configs/nvim/init.lua";
      awmconf = "nvim /home/jmug/nixos/home-modules/explicit-configs/awesome/rc.lua";
      # TODO END Interpolate the name of the host here.
      rshellconf = "source ~/.zshrc";
      rlogiops = "sudo systemctl restart logid"; # Restart the logid daemon.
      # TODO: Interpolate the name of the host here.
      nrsw = "sudo nixos-rebuild switch --flake /home/jmug/nixos#nixlap"; # parametrize this as home dir.
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      font = {
        size = 8.6;
        normal.family = "BigBlueTermPlus Nerd Font";
      };
      window.opacity = 0.9;
      colors = {
        bright = {
          black = "#575b70";
          blue = "#caa9fa";
          cyan = "#9aedfe";
          green = "#5af78e";
          magenta = "#ff92d0";
          red = "#ff6e67";
          white = "#e6e6e6";
          yellow = "#f4f99d";
        };
        normal = {
          black = "#000000";
          blue = "#caa9fa";
          cyan = "#8be9fd";
          green = "#50fa7b";
          magenta = "#ff79c6";
          red = "#ff5555";
          white = "#bfbfbf";
          yellow = "#f1fa8c";
        };
        primary = {
          background = "#282a36";
          foreground = "#f8f8f2";
        };
      };
    };
  };

  services.autorandr.enable = true;
  programs.autorandr = {
    enable = true;
    profiles = {
      laptop = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
        };
        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            mode = "2256x1504";
          };
        };
      };
      docked_open_dp8 = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          "DP-8" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "eDP-1" = {
            position = "592x1440";
            enable = true;
            mode = "2256x1504";
          };
          "DP-8" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_closed_dp8 = {
        fingerprint = {
          "DP-8" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "DP-8" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_open_dp7 = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          "DP-7" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "eDP-1" = {
            position = "592x1440";
            enable = true;
            mode = "2256x1504";
          };
          "DP-7" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_closed_dp7 = {
        fingerprint = {
          "DP-7" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "DP-7" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_open_dp5 = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          "DP-5" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "eDP-1" = {
            position = "592x1440";
            enable = true;
            mode = "2256x1504";
          };
          "DP-5" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_closed_dp5 = {
        fingerprint = {
          "DP-5" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "DP-5" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_open_dp3 = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          "DP-3" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "eDP-1" = {
            position = "592x1440";
            enable = true;
            mode = "2256x1504";
          };
          "DP-3" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
      docked_closed_dp3 = {
        fingerprint = {
          "DP-3" = "00ffffffffffff001e6d5677061e030003210104b5522278ffa105a9564ba4250f5054210800d1c0614001010101010101010101010148d570b0d0a0465038203a00345a3100001a000000fd003064979737010a202020202020000000fc004c472048445220575148440a20000000ff003330334d58554e36303239340a01840203287423090707830100004410040301e2006ae305c000e606050153535d681a00000101306400e2b370b0d0a03b5038203a00345a3100001a0d7f70b0d0a03c5038203a00345a3100001adc6970b0d0a03c5038203a00345a3100001a0000000000000000000000000000000000000000000000000000000000000000004a";
        };
        config = {
          "DP-3" = {
            enable = true;
            primary = true;
            mode = "3440x1440";
            rate = "100.00";
          };
        };
      };
    };
  };
  
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "git" = {
        host = "github.com";
        user = "git";
        identityFile = [
          "/home/jmug/.ssh/id_yubikey" # Auto updated symlik that matches all yubikeys.
          "/home/jmug/.ssh/id_jmug" # Fallback key with passphrase.
        ];
      };
      "forgejo" = {
        host = "code.jmug.me";
        user = "forgejo";
        identityFile = [
          "/home/jmug/.ssh/id_yubikey" # Auto updated symlik that matches all yubikeys.
          "/home/jmug/.ssh/id_jmug" # Fallback key with passphrase.
        ];
      };
      alarm = {
        user = "alarm";
        hostname = "alarm";
        forwardAgent = true;
        identityFile = "/home/jmug/.ssh/id_ed25519";
      };
      wsl = {
        user = "jmug";
        hostname = "192.168.10.241";
        port = 69;
        forwardAgent = true;
        identityFile = [
          "/home/jmug/.ssh/id_yubikey" # Auto updated symlik that matches all yubikeys.
        ];
      };
      ws = {
        user = "jmug";
        hostname = "98.59.213.212";
        port = 69;
        forwardAgent = true;
        identityFile = [
          "/home/jmug/.ssh/id_yubikey" # Auto updated symlik that matches all yubikeys.
        ];
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
