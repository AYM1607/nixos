{ lib, config, inputs, pkgs, ...} :
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
    # TODO: Move all hyprland related config to its own module.
    ../../home-modules/hyprland

    ../../home-modules/direnv.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/nvim.nix
    ../../home-modules/sops.nix
    ../../home-modules/ssh-client.nix
    ../../home-modules/starship.nix
    ../../home-modules/tmux.nix
    ../../home-modules/zsh.nix
  ];

  ghostty.font-size = "14";
  ghostty.window-decoration = false;

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    packages = with pkgs; [
      # Media
      loupe
      vlc
      # Audio
      wireplumber
      spotify-player
      # Screen management
      brightnessctl
      # Secret management.
      age
      sops
      # Browsers
      ungoogled-chromium
      # Coms
      (webcord.override { electron = inputs.nixpkgs-electron-32.legacyPackages."aarch64-linux".electron; })
      whatsie
      obs-studio
    ];

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
      name = "Posy_Cursor_Black";
      package = pkgs."posy-cursors";
    };

    file = {} // yubikeyPublicKeyEntries;

    stateVersion = "25.05"; # Do not change!!!
  };

  gtk = {
    enable = true;
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };
  };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

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


  programs.zsh.shellAliases = {
    # TODO: Interpolate the name of the host here.
    nrsw = "sudo nixos-rebuild switch --flake /home/jmug/nixos#asahi"; # parametrize this as home dir.
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
