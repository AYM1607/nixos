{ pkgs, ... }: {

  home = {
    packages = with pkgs; [
      tmux
    ];
  };

  programs.zsh = {
    shellAliases = {
      t = "tmux";
      ta = "tmux attach -t";
      tns = "tmux new-session -t";
      tks = "tmux kill-session -t";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    prefix = "C-a";
    terminal = "screen-256color";
    historyLimit = 5000;
    baseIndex = 1;
    escapeTime = 10;
    customPaneNavigationAndResize = true;
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color*:Tc"
      # Keep path when creating a new window.
      bind c new-window -c "#{pane_current_path}"

      # Better splits
      bind-key "|" split-window -h -c "#{pane_current_path}"
      bind-key "\\" split-window -fh -c "#{pane_current_path}"
      bind-key "-" split-window -v -c "#{pane_current_path}"
      bind-key "_" split-window -fv -c "#{pane_current_path}"

      # Toggle last windows
      bind Space last-window
      bind -r p previous-window
      bind -r f next-window

      # Movement
      bind -r e select-pane -U
      bind -r n select-pane -D
      bind -r m select-pane -L
      bind -r i select-pane -R

      # Resizing this will not work with colemak keymaps.
      bind -r C-j resize-pane -D 15
      bind -r C-k resize-pane -U 15
      bind -r C-h resize-pane -L 15
      bind -r C-l resize-pane -R 15

      # Kill panes and windows
      bind w kill-pane
      bind W kill-window

      # Pane sync
      unbind s
      unbind S
      bind s setw synchronize-panes on
      bind S setw synchronize-panes off
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '1' # minutes
        '';
      }
    ];
  };

}
