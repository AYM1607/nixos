{ lib, config, pkgs, ...} :
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
    ../../home-modules/nvim.nix
    ../../home-modules/zsh.nix
    ../../home-modules/git.nix
    ../../home-modules/lazygit.nix
    ../../home-modules/starship.nix
    ../../home-modules/ghostty-config.nix
    ../../home-modules/sops.nix
  ];

  home = {
    username = "jmug";
    homeDirectory = "/home/jmug";

    packages = with pkgs; [
      # Secret management.
      age
      sops
    ];

    file = {} // yubikeyPublicKeyEntries;

    stateVersion = "25.05"; # Do not change!!!
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
