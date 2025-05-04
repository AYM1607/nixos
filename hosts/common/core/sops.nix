{ inputs, config, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };

  sops.secrets = {
    "wireless.env" = {};

    "yubico/u2f_keys/jmug" = {
      owner = config.users.users.jmug.name;
      inherit (config.users.users.jmug) group;
      path = "/home/jmug/.config/Yubico/u2f_keys";
    };
  };
}
