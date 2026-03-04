{ user, ... } : {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        identityAgent = "${user.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
      };
    };
  };
}
