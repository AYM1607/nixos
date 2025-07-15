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
      "private_keys/ace" = {
        path = "/home/jmug/.ssh/id_ace";
      };
      "aws/jmug_ace_mfa_serial" = {};
      "aws/role_arn" = {};
    };
  };
}
