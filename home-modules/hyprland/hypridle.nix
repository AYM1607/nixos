{ ... } : {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";        # Avoid starting hyprlock multiple times.
        before_sleep_cmd = "pidof hyprlock || hyprlock --no-fade-in --immediate";     # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on";   # to avoid having to press a key twice to turn on the display.
        inhibit_sleep = 3;                              # Wait for hyprlock.
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 10";     # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r";             # monitor backlight restore.
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";       # lock screen when timeout has passed.
        }
        {
          timeout = 630;
          on-timeout = "hyprctl dispatch dpms off";                     # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r";   # screen on when activity is detected after timeout has fired.
        }
      ];
    };
  };
}
