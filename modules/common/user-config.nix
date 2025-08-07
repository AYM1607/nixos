{ lib, pkgs, config, ... }:

{
  options.user = lib.mkOption {
    type = lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Primary username for the system";
        };

        homeDirectory = lib.mkOption {
          type = lib.types.str;
          description = "Home directory path for the user";
          default =
            if pkgs.stdenv.isDarwin
            then "/Users/${config.user.name}"
            else "/home/${config.user.name}";
        };
      };
    };
    description = "User configuration options";
  };
}
