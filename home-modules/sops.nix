{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/jmug/.config/sops/age/keys.txt";

    defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "private_keys/jmug" = {
        path = "/home/jmug/.ssh/id_jmug";
      };
      "private_keys/matcha" = {
        path = "/home/jmug/.ssh/id_matcha";
      };
    };
  };
}
