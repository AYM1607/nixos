{ user, ... } : {
  programs.ssh = {
    enable = true;
    extraConfig = ''
Host *
  IdentityAgent ${user.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
    '';
  };
}
