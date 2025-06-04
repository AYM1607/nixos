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
    ../../home-modules/zsh.nix
    ../../home-modules/direnv.nix
    ../../home-modules/nvim.nix
    ../../home-modules/tmux.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/sops.nix
    inputs.walker.homeManagerModules.default
  ];

  ghostty.font-size = "14";
  ghostty.window-decoration = false;

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    packages = with pkgs; [
      # Audio
      wireplumber
      # Screen management
      brightnessctl
      # Secret management.
      age
      sops
      # Browsers
      ungoogled-chromium
      # TODO: Remove this when moving to fully yubi module.
      yubioath-flutter
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

  programs.walker = {
    enable = true;

    config = {
      ui.fullscreen = true;
      list = {
        height = 200;
      };
      websearch.prefix = "?";
    };
  };
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["/home/jmug/Wallpapers/nyc2.jpg"];
      wallpaper = [", /home/jmug/Wallpapers/nyc2.jpg"];
      ipc = true;
    };
  };
  programs.waybar = {
    enable = true;
    settings = [
      {
        # "layer": "top", # Waybar at top layer
        # "position": "bottom", # Waybar position (top|bottom|left|right)
        height = 30; # Waybar height (to be removed for auto height)
        # "width": 1280, # Waybar width
        spacing = 4; # Gaps between modules (4px)
        # Choose the order of the modules
        modules-left = [
            "hyprland/workspaces"
        ];
        modules-center = [
            "hyprland/window"
        ];
        modules-right = [
            "mpd"
            "idle_inhibitor"
            "wireplumber"
            "network"
            "power-profiles-daemon"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "keyboard-state"
            "sway/language"
            "battery"
            "battery#bat2"
            "clock"
            "tray"
            "custom/power"
        ];
        # Modules configuration
        "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{name} {icon}";
            format-icons = {
                active = "";
                default = "";
            };
        };
        keyboard-state = {
            numlock = true;
            capslock = true;
            format = "{name} {icon}";
            format-icons = {
                locked = "";
                unlocked = "";
            };
        };
        # "sway/mode": {
        #     "format": "<span style=\"italic\">{}</span>"
        # },
        # "sway/scratchpad": {
        #     "format": "{icon} {count}",
        #     "show-empty": false,
        #     "format-icons": ["", ""],
        #     "tooltip": true,
        #     "tooltip-format": "{app}: {title}"
        # },
        mpd = {
            format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
            format-disconnected = "Disconnected ";
            format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
            unknown-tag = "N/A";
            interval = 5;
            consume-icons = {
                on = " ";
            };
            random-icons = {
                off = "<span color=\"#f53c3c\"></span> ";
                on = " ";
            };
            repeat-icons = {
                on = " ";
            };
            single-icons = {
                on = "1 ";
            };
            state-icons = {
                paused = "";
                playing = "";
            };
            tooltip-format = "MPD (connected)";
            tooltip-format-disconnected = "MPD (disconnected)";
        };
        idle_inhibitor = {
            format = "{icon}";
            format-icons = {
                activated = "";
                deactivated = "";
            };
        };
        tray = {
            # "icon-size": 21,
            spacing = 10;
            # "icons": {
            #   "blueman": "bluetooth",
            #   "TelegramDesktop": "$HOME/.local/share/icons/hicolor/16x16/apps/telegram.png"
            # }
        };
        clock = {
            # "timezone": "America/New_York",
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
        };
        cpu = {
            format = "{usage}% ";
            tooltip = false;
        };
        memory = {
            format = "{}% ";
        };
        temperature = {
            # "thermal-zone": 2,
            # "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
            critical-threshold = 80;
            # "format-critical": "{temperatureC}°C {icon}",
            format = "{temperatureC}°C {icon}";
            format-icons = ["" "" ""];
        };
        backlight = {
            # "device": "acpi_video1",
            format = "{percent}% {icon}";
            format-icons = ["" "" "" "" "" "" "" "" ""];
        };
        battery = {
            states = {
                # "good": 95,
                warning = 30;
                critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            # "format-good": "", // An empty format will hide the module
            # "format-full": "",
            format-icons = ["" "" "" "" ""];
        };
        "battery#bat2" = {
            bat = "BAT2";
        };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };
        network = {
            # "interface": "wlp2*", // (Optional) To force the use of this interface
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        wireplumber = {
            format = "{volume}% {icon}";
            format-muted = "";
            # on-click = "helvum";
            max-volume = 150;
            scroll-step =  0.15;
            format-icons = [" " " " " "];
        };
        "custom/media" = {
            format = "{icon} {text}";
            return-type = "json";
            max-length = 40;
            format-icons = {
                spotify = "";
                default = "🎜";
            };
            escape = true;
            exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder;
            # "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" // Filter player based on name
        };
        "custom/power" = {
            format  = "⏻ ";
            tooltip = false;
            menu = "on-click";
            menu-file = "$HOME/.config/waybar/power_menu.xml"; # Menu file in resources folde;
            "menu-actions" = {
                shutdown = "shutdown";
                reboot = "reboot";
                suspend = "systemctl suspend";
                hibernate = "systemctl hibernate";
            };
        };
      }
    ];
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

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "waybar"
    ];
    monitor = [
      ",preferred,auto,auto"
      "eDP-1,preferred,auto,1.6"
    ];

    "$terminal" = "ghostty";
    "$fileManager" = "dolphin"; # TODO: Change.
    "$menu" = "wofi --show drun"; # TODO: Change.

    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    general = {
      gaps_in = 4;
      gaps_out = 8;

      border_size = 1;

      # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      # Set to true enable resizing windows by clicking and dragging on borders and gaps
      resize_on_border = false;

      # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
      allow_tearing = false;

      layout = "dwindle";
    };

    decoration = {
      rounding = 5;
      rounding_power = 2;

      # Change transparency of focused and unfocused windows
      active_opacity = "1.0";
      inactive_opacity = "1.0";

      shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#blur
      blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = "0.1696";
      };
    };

    animations = {
      # enabled = yes, please :)
      enabled = "no";
    };

    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle = {
      pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = true; # You probably want this
    };

    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master = {
      new_status = "master";
    };

    # https://wiki.hyprland.org/Configuring/Variables/#misc
    misc = {
      force_default_wallpaper = 1; # Set to 0 or 1 to disable the anime mascot wallpapers
      disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
    };

# https://wiki.hyprland.org/Configuring/Variables/#input
    input = {
      kb_layout = "us";

      follow_mouse = 1;

      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

      touchpad = {
        natural_scroll = true;
        tap-to-click = false;
        disable_while_typing = true;
        clickfinger_behavior = true; # Right click with 2 fingers.
        scroll_factor = "0.75";
      };
    };

    gestures = {
      workspace_swipe = false;
    };

    "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind = [
      "$mainMod, return, exec, $terminal"
      "$mainMod, Q, killactive,"
      "$mainMod SHIFT, Q, exit,"
      # "$mainMod, E, exec, $fileManager"
      "$mainMod, V, togglefloating,"
      "$mainMod, R, exec, $menu"
      "$mainMod, P, pseudo," # dwindle
      "$mainMod, J, togglesplit," # dwindle

      # Move focus with mainMod + arrow keys
      "$mainMod, M, movefocus, l"
      "$mainMod, I, movefocus, r"
      "$mainMod, N, movefocus, d"
      "$mainMod, E, movefocus, u"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"

      # Example special workspace (scratchpad)
      "$mainMod, S, togglespecialworkspace, magic"
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      # Scroll through existing workspaces with mainMod + scroll
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"

      # App launcher
      "$mainMod, space, exec, GSK_RENDERER=ngl walker"
    ];

    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    bindl = [
      # Requires playerctl
      " , XF86AudioNext, exec, playerctl next"
      " , XF86AudioPause, exec, playerctl play-pause"
      " , XF86AudioPlay, exec, playerctl play-pause"
      " , XF86AudioPrev, exec, playerctl previous"
    ];

    ##############################
    ### WINDOWS AND WORKSPACES ###
    ##############################

    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
    # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

    # Example windowrule
    # windowrule = float,class:^(kitty)$,title:^(kitty)$

    windowrule = [
    # Ignore maximize requests from apps. You'll probably like this.
      "suppressevent maximize, class:.*"
    # Fix some dragging issues with XWayland
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    ];
  };

  programs.zsh.shellAliases = {
    # TODO: Interpolate the name of the host here.
    nrsw = "sudo nixos-rebuild switch --flake /home/jmug/nixos#asahi"; # parametrize this as home dir.
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
