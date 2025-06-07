{ ... } : {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "waybar"
    ];
  };
  home.file.".config/waybar/style.css" = {
    text = ''
    * {
      font-family: "CaskaydiaCove Nerd Font", "Font Awesome 6 Free", "Font Awesome 6 Free Solid";
      font-weight: bold;
      font-size: 16px;
      color: #dcdfe1;
    }

    #waybar {
      background-color: rgba(0, 0, 0, 0);
      border: none;
      box-shadow: none;
    }

    #workspaces,
    #window,
    #tray{
      /*background-color: rgba(29,31,46, 0.95);*/
      background-color: rgba(15,27,53,0.9);
      padding: 4px 6px;
      margin-top: 6px;
      margin-left: 6px;
      margin-right: 6px;
      border-radius: 10px;
      border-width: 0px;
    }

    #clock,
    #custom-power{
      background-color: rgba(15,27,53,0.9);
      margin-top: 6px;
      margin-right: 6px;
      /*margin-bottom: 4px;*/
      padding: 4px 2px;
      border-radius: 0 10px 10px 0;
      border-width: 0px;
    }

    #idle_inhibitor,
    #custom-lock{
      background-color: rgba(15,27,53,0.9);
      margin-top: 6px;
      margin-left: 6px;
      /*margin-bottom: 4px;*/
      padding: 4px 2px;
      border-radius: 10px 0 0 10px;
      border-width: 0px;
    }

    #custom-reboot,
    #bluetooth,
    #battery,
    #wireplumber,
    #backlight,
    #network,
    #custom-temperature,
    #memory,
    #cpu{
      background-color: rgba(15,27,53,0.9);
      margin-top: 6px;
      /*margin-bottom: 4px;*/
      padding: 4px 2px;
      border-width: 0px;
    }

    #custpm-temperature.critical,
    #pulseaudio.muted {
      color: #FF0000;
      padding-top: 0;
    }

    #bluetooth:hover,
    #network:hover,
    /*#tray:hover,*/
    #backlight:hover,
    #battery:hover,
    #pulseaudio:hover,
    #custom-temperature:hover,
    #memory:hover,
    #cpu:hover,
    #clock:hover,
    #custom-lock:hover,
    #custom-reboot:hover,
    #custom-power:hover,
    /*#workspaces:hover,*/
    #window:hover {
      background-color: rgba(70, 75, 90, 0.9);
    }

    #workspaces button:hover{
      background-color: rgba(97, 175, 239, 0.2);
      padding: 2px 8px;
      margin: 0 2px;
      border-radius: 10px;
    }

    #workspaces button.active {
      background-color: #61afef; /* 蓝色高亮 */
      color: #ffffff;
      padding: 2px 8px;
      margin: 0 2px;
      border-radius: 10px;
    }

    #workspaces button {
      background: transparent;
      border: none;
      color: #888888;
      padding: 2px 8px;
      margin: 0 2px;
      font-weight: bold;
    }

    #window {
      font-weight: 500;
      font-style: italic;
    }
    '';
  };
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 0;
        modules-left = [
          "hyprland/workspaces"
          "tray"
          "custom/lock"
          "custom/reboot"
          "custom/power"
        ];
        modules-center = [];
        modules-right = [
            "idle_inhibitor"
            "network"
            "wireplumber"
            "cpu"
            "memory"
            "backlight"
            "battery"
            "battery#bat2"
            "clock"
        ];
        # Modules configuration
        "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{name} {icon}";
            on-click =  "activate";
            persistent-workspaces = {
              "*" = [ 1 2 3 4 5 6 7 8 9 ];
            };
            format-icons = {
              "1" = "";
              "7" = "󰓇";
              "8" = "";
              "9" = "󰍨";
              "default" = "";
            };
        };
        idle_inhibitor = {
            format = " {icon}";
            format-icons = {
                activated = "󰾨 ";
                deactivated = "󱡥 ";
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
            format = "<span color='#FF9F0A'>  </span>{usage}% ";
            tooltip = false;
        };
        memory = {
            format = "<span color='#8A2BE2'>  </span>{}% ";
        };
        backlight = {
            format = "<span color='#FFD700'> {icon}</span>{percent}% ";
            format-icons = [" " " " " " " " " " " " " " " " " "];
        };
        battery = {
            states = {
                warning = 30;
                critical = 15;
            };
            format = "<span color='#28CD41'> {icon} </span>{capacity}% ";
            format-charging = "<span color='#28CD41'>  </span>{capacity}% ";
            format-icons = ["" "" "" "" ""];
            interval = 1;
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
          format-wifi = "<span color='#00FFFF'>  </span> ";
          format-ethernet =  "<span color='#7FFF00'> {ipaddr} 󰈀 </span> ";
          tooltip-format = "{essid}({ifname}) -> {ipaddr}/{cidr}";
          format-linked = "<span color='#FFA500'> 󱘖 </span>{ifname} (No IP) ";
          format-disconnected = "<span color='#FF4040'>  </span>Disconnected ";
          interval = 1;
        };
        wireplumber = {
            format = " {icon} {volume}% ";
            format-muted = "<span color='#FF4040'>  </span>";
            # on-click = "helvum";
            max-volume = 150;
            scroll-step =  0.15;
            format-icons = ["" " " " "];
        };
        "custom/lock" = {
          format = "<span color='#00FFFF'>  </span>";
          on-click =  "hyprlock";
          tooltip = true;
          tooltip-format = "lock";
        };
        "custom/reboot" = {
          format = "<span color='#FFD700'>  </span>";
          on-click = "systemctl reboot";
          tooltip = true;
          tooltip-format = "reboot";
        };
        "custom/power" = {
          format = "<span color='#FF4040'>  </span>";
          on-click = "systemctl poweroff";
          tooltip = true;
          tooltip-format = "poweroff";
        };
      }
    ];
  };
}
