{ ... }: {
  home.file.".config/ghostty/config" = {
    text = ''
    # If not preset, this causes issues when sshing into linux servers.
    term = xterm-256color
    font-family = "BigBlueTermPlus Nerd Font"
    font-size = 17.2
    theme = "PaleNight"
    background-opacity = 0.9
    window-decoration = false

    # This is the default to open the configuration
    # I type this by accident way to frequently...
    keybind = ctrl+comma=unbind
    '';
  };
  home.file.".config/ghostty/themes/PaleNight" = {
    text = ''
    palette = 0=#000000
    palette = 1=#ff5555
    palette = 2=#50fa7b
    palette = 3=#f1fa8c
    palette = 4=#caa9fa
    palette = 5=#ff79c6
    palette = 6=#8be9fd
    palette = 7=#bfbfbf
    palette = 8=#575b70
    palette = 9=#ff6e67
    palette = 10=#5af78e
    palette = 11=#f4f99d
    palette = 12=#caa9fa
    palette = 13=#ff92d0
    palette = 14=#9aedfe
    palette = 15=#e6e6e6
    background = 282a36
    foreground = f8f8f2
    cursor-color = #ffcb6b
    selection-background = #717cb4
    selection-foreground = #80cbc4
    '';
  };
}
