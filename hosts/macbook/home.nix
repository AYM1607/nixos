{
  config,
  pkgs,
  pkgs-unstable,
  ...
} : {
  
  imports = [
    ../../home-modules/tmux.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/zsh.nix
    ../../home-modules/starship.nix
    ../../home-modules/nvim.nix
    ../../home-modules/direnv.nix
    # I should update the module with an option for adding winodow decorations.
    ../../home-modules/ghostty-config.nix
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
    username = "uagm";
    homeDirectory = "/Users/uagm";

    packages = with pkgs; [
      fzf
      ripgrep
      exercism
      typescript-language-server
      lua-language-server
      starship
      audacity
      pkgs-unstable.claude-code
      (pkgs-unstable.litellm.overrideAttrs (oldAttrs: rec {
        version = "1.74.9";
        src = pkgs.fetchFromGitHub {
          owner = "BerriAI";
          repo = "litellm";
          tag = "v${version}-stable";
          hash = "sha256-SGZwt2jzAQbOMlvudqPWat281su6OwT7JG2CNSMjL3A=";
        };
      }))
      pkgs-unstable.opencode
    ];

    stateVersion = "24.11";
  };

  programs.zsh = {
    shellAliases = {
      # TODO BEGIN Interpolate the name of the host here.
      flakeconf = "nvim /Users/uagm/nixos/flake.nix";
      sysconf = "nvim /Users/uagm/nixos/hosts/macbook/configuration.nix";
      homeconf = "nvim /Users/uagm/nixos/hosts/macbook/home.nix";
      nvconf = "nvim /Users/uagm/nixos/home-modules/explicit-configs/nvim/init.lua";
      # TODO: Interpolate the name of the host here.
      nrsw = "sudo darwin-rebuild switch --flake /Users/uagm/nixos#macbook";
    };
  };
}
