{
  lib,
  inputs,
  config,
  pkgs,
  ssh-agent-switcher,
  user,
  ...
} :
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
  username = user.name;
  homeDirectory = user.homeDirectory;
in {

  imports = [
    ../../home-modules/hyprland

    ../../home-modules
    ../../home-modules/direnv.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/nvim.nix
    ../../home-modules/sops.nix
    # ../../home-modules/ssh-client.nix
    ../../home-modules/starship.nix
    ../../home-modules/tmux.nix
    ../../home-modules/zsh.nix

    inputs.zen-browser.homeModules.beta
  ];

  # Custom options for my packages.
  nvim = {
    enable = true;
  };
  ghostty = {
    font-size = "14";
    window-decoration = false;
  };
  programs.zen-browser.enable = true;

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      # Media
      loupe
      vlc
      bluetui
      # Audio
      wireplumber
      spotify-player
      # Secret management.
      age
      sops
      # Browsers
      firefox
      # Coms
      discord
      slack
      obs-studio

      # AWS tools
      # awscli2
      # (callPackage ../../nixos-modules/shell-apps/aws-cli-mfa.nix {})

      # Minecraft
      prismlauncher

      # Misc
      # zig
      fastfetch
      fzf
      ripgrep
      git
      wget
      exercism
    ];

    file = {} // yubikeyPublicKeyEntries;

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
      name = "Posy_Cursor_Black";
      package = pkgs."posy-cursors";
    };

    stateVersion = "25.11";
  };

  # home.activation.aws-cli-mfa-config = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   mkdir -p ~/.config/aws-cli-mfa
  #   cat > ~/.config/aws-cli-mfa/config.yaml << EOF
# mfa_serial: $(cat ${config.sops.secrets."aws/jmug_matcha_mfa_serial".path})
# role_arn: $(cat ${config.sops.secrets."aws/role_arn".path})
# session_duration: 43200
# EOF
  # '';

  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      # flakeconf = "sudo nvim /etc/nixos/flake.nix";
      # nosconf = "sudo nvim /etc/nixos/hosts/devbox/configuration.nix";
      # homeconf = "sudo nvim /etc/nixos/hosts/devbox/home.nix";
      # nvconf = "sudo nvim /etc/nixos/home-modules/explicit-configs/nvim/init.lua";
      # TODO END Interpolate the name of the host here.
      rshellconf = "source ~/.zshrc";
      # TODO: Interpolate the name of the host here.
      nrsw = "sudo nixos-rebuild switch --flake ${homeDirectory}/nixos#nixbox";
      fly = "flyctl";
      # awsmfa = "eval $(aws-cli-mfa)";
      # uawsmfa = "eval $(aws-cli-mfa --unset)";
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
    };
    # matchBlocks = {
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
