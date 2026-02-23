{
  config,
  pkgs,
  pkgs-unstable,
  opencode-tunneler,
  godig,
  user,
  ...
} :
let
  username = user.name;
  homeDirectory = user.homeDirectory;
in {
  
  imports = [
    ../../home-modules/default.nix
    ../../home-modules/direnv.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/git.nix
    ../../home-modules/homebrew.nix
    ../../home-modules/karabiner.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/nvim.nix
    ../../home-modules/secretive.nix
    ../../home-modules/starship.nix
    ../../home-modules/tmux.nix
    ../../home-modules/opencode-config.nix
    ../../home-modules/zsh.nix
  ];

  ghostty = {
    font-size = "17.2";
    window-decoration = true;
  };

  nvim = {
    enable = true;
    package = pkgs-unstable.neovim;
  };

  home = {
    username = username;
    homeDirectory = homeDirectory;

    packages = with pkgs; [
      pkgs-unstable.cmake
      clang

      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
      exercism
      typescript-language-server # TODO: Defer to individual projects.
      audacity
      (pkgs-unstable.litellm.overrideAttrs (oldAttrs: rec {
        version = "1.74.9";
        src = pkgs.fetchFromGitHub {
          owner = "BerriAI";
          repo = "litellm";
          tag = "v${version}-stable";
          hash = "sha256-SGZwt2jzAQbOMlvudqPWat281su6OwT7JG2CNSMjL3A=";
        };
      }))
      pkgs-unstable.vscode
      pkgs-unstable.ngrok
      pkgs-unstable.flyctl
      pkgs-unstable.awscli2
      pkgs-unstable.google-cloud-sdk

      pkgs-unstable.go
      pkgs-unstable.gopls
      pkgs-unstable.gotools
      pkgs-unstable.bun
      pkgs-unstable.rustup
      # Expo.
      pkgs-unstable.nodejs_24
      pkgs-unstable.eas-cli

      opencode-tunneler.packages.aarch64-darwin.default
      godig.packages.aarch64-darwin.service
    ];

    stateVersion = "24.11";
  };

  programs.ssh = {
    matchBlocks = {
      media = {
        user = "jmug";
        hostname = "192.168.8.241";
        forwardAgent = true;
      };
      handmade = {
        user = "jmug";
        hostname = "82.180.160.149";
        forwardAgent = true;
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      flakeconf = "nvim ${homeDirectory}/nixos/flake.nix";
      sysconf = "nvim ${homeDirectory}/nixos/hosts/macbook/configuration.nix";
      homeconf = "nvim ${homeDirectory}/nixos/hosts/macbook/home.nix";
      nvconf = "nvim ${homeDirectory}/nixos/home-modules/explicit-configs/nvim/init.lua";

      rshellconf = "source ${homeDirectory}/.zshrc";
      nrsw = "sudo darwin-rebuild switch --flake ${homeDirectory}/nixos#macbook";
      opencode-local = "${homeDirectory}/dev/opencode/dist-local/bin/opencode";
    };

    initContent = ''
      export PATH=$PATH:$HOME/bin
      export PATH=$PATH:$HOME/.opencode/bin
      export PATH=$PATH:$HOME/.local/bin
    '';
  };
}
