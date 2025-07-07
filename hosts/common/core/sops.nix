{ inputs, config, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../../secrets.yaml;
    validateSopsFiles = false;

    # To bootstrap a new device you need to ensure
    # that the ssh service was enabled at least once
    # (if you don't plan to keep it enabled permanently)
    # then you need to derive an age public key from the
    # ssh key by using:
    #
    # $ nix-shell -p ssh-to-age
    # $ sudo ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
    #
    # This will give you the public key that you must put under .sops.yaml
    # at the root of this repo.
    #
    # You'll then need to bootsrap the environment, so copy the secret key from
    # cold storage to ~/.config/sops/age/keys.txt
    # chomd it to 755
    #
    # The run:
    # $ nix-shell -p sops
    # $ sops updatekeys secrets.yaml
    #
    # You're bootsrapet and good to go!
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
