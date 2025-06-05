{ inputs, config, pkgs, ssh-agent-switcher, ... } :
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
  ];

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    packages = with pkgs; [
      zig
      neofetch
      fzf
      ripgrep
      htop
      git
      wget
      exercism
      # Thin provisioning tools
      thin-provisioning-tools
    ];

    stateVersion = "24.11";
  };

  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      flakeconf = "sudo nvim /etc/nixos/flake.nix";
      nosconf = "sudo nvim /etc/nixos/hosts/devbox/configuration.nix";
      homeconf = "sudo nvim /etc/nixos/hosts/devbox/home.nix";
      nvconf = "sudo nvim /etc/nixos/home-modules/explicit-configs/nvim/init.lua";
      # TODO END Interpolate the name of the host here.
      rshellconf = "source ~/.zshrc";
      # TODO: Interpolate the name of the host here.
      nrsw = "sudo nixos-rebuild switch --flake /home/jmug/nixos#devbox";
    };
    loginExtra = ''
    if [ ! -e "/tmp/ssh-agent.''${USER}" ]; then
      if [ -n "''${ZSH_VERSION}" ]; then
          eval ${ssh-agent-switcher.packages.x86_64-linux.default}/bin/ssh-agent-switcher 2>/dev/null "&!"
      else
          ${ssh-agent-switcher.packages.x86_64-linux.default}/bin/ssh-agent-switcher 2>/dev/null &
          disown 2>/dev/null || true
      fi
    fi
    export SSH_AUTH_SOCK="/tmp/ssh-agent.''${USER}"
    '';
  };
  
  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "confirm";
    # matchBlocks = {
    #   alarm = {
    #     user = "alarm";
    #     hostname = "alarm";
    #     forwardAgent = true;
    #     identityFile = "/home/jmug/.ssh/id_ed25519";
    #   };
    #   wsl = {
    #     user = "aym";
    #     hostname = "192.168.10.241";
    #     port = 69;
    #     forwardAgent = true;
    #     identityFile = "/home/jmug/.ssh/id_ed25519";
    #   };
    #   ws = {
    #     user = "aym";
    #     hostname = "73.118.150.68";
    #     port = 69;
    #     forwardAgent = true;
    #     identityFile = "/home/jmug/.ssh/id_ed25519";
    #   };
    # };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
