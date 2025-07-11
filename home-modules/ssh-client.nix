{ lib, config, ... } : {

  options.ssh-client = {
    add-alarm = lib.mkEnableOption "add the alarm match block";
  };

  config.services.ssh-agent.enable = true;
  config.programs.ssh = {
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
        user = "git";
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
    } // lib.optionalAttrs config.ssh-client.add-alarm {
      alarm = {
        user = "alarm";
        hostname = "alarm";
        forwardAgent = true;
        identityFile = "/home/jmug/.ssh/id_ed25519";
      };
    };
  };
}
