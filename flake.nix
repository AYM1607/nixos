{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Required for webcord.
    nixpkgs-electron-32.url = "github:NixOS/nixpkgs/782740762fb281404740b6b7084d356c3dab1173";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management.
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2025-05-30";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Wayland app-launcher
    walker = {
      url = "github:abenz1267/walker/v0.12.23";
    };

    # ssh-agent forwarder for linux.
    ssh-agent-switcher = {
      url = "github:AYM1607/ssh-agent-switcher/6cd7ce973cf08656d42e475945216d8c0f0b0c7b";
    };

    opencode-tunneler = {
      url = "github:AYM1607/opencode-tunneler";
      inputs.nixpkgs.follows = "nixpkgs-unstable";  # Use same nixpkgs
    };

    godig = {
      url = "github:AYM1607/godig/v0.2.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";  # Use same nixpkgs
    };

    # Zen browser.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
        # to have it up-to-date or simply don't specify the nixpkgs input
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    apple-silicon,
    nixos-hardware,
    home-manager,
    ghostty,
    nixgl,
    ssh-agent-switcher,
    opencode-tunneler,
    godig,
    ...
  }@inputs: {
    nixosConfigurations = {
      nixlap = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs ghostty;
        };
        modules = [
          ./hosts/nixlap/configuration.nix
          nixos-hardware.nixosModules.framework-13-7040-amd
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jmug = import ./hosts/nixlap/home.nix;
            home-manager.users.root = import ./hosts/nixlap/home-root.nix;
          }
        ];
      };
      asahi = let
        pkgs-unstable_aarch64-linux = import nixpkgs-unstable {
          system = "aarch64-linux";
          config = {
            allowUnfree = true;
          };
        };
      in nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs apple-silicon ghostty;
        };
        modules = [
          ./hosts/asahi/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              pkgs-unstable = pkgs-unstable_aarch64-linux;
              inherit inputs;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jmug = import ./hosts/asahi/home.nix;
          }
        ];
      };
      devbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs ghostty;
        };
        modules = [
          ./hosts/devbox/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs ssh-agent-switcher; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jmug = import ./hosts/devbox/home.nix;
            home-manager.users.root = import ./hosts/devbox/home-root.nix;
          }
        ];
      };
      nixbox = let
        pkgs-unstable_x86_64-linux = import nixpkgs-unstable {
          system = "x86_64-linux";
          config = {
            allowUnfree = true;
          };
        };
      in nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs ghostty;
        };
        modules = [
          ./hosts/nixbox/configuration.nix
          home-manager.nixosModules.home-manager
          ({config, ...}: {
            home-manager.extraSpecialArgs = {
              pkgs-unstable = pkgs-unstable_x86_64-linux;
              inherit inputs;
              inherit ssh-agent-switcher;
              inherit (config) user;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jmug = import ./hosts/nixbox/home.nix;
            # home-manager.users.root = import ./hosts/devbox/home-root.nix;
          })
        ];
      };
    };

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations = let
      pkgs-unstable_aarch64-darwin = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };
    in {
      "macbook" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs ghostty self;
        };
        modules = [
          ./hosts/macbook/configuration.nix
          home-manager.darwinModules.home-manager
          ({ config, ... }: {
            home-manager.extraSpecialArgs = {
              pkgs-unstable = pkgs-unstable_aarch64-darwin;
              inherit (config) user;
              inherit opencode-tunneler;
              inherit godig;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jmug.imports = [ ./hosts/macbook/home.nix ];
          })
        ];
      };
    };

    homeConfigurations = let
      pkgs-unstable_x86_64-linux = import nixpkgs-unstable {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
      };
    in {
      alarm = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-linux";
        modules = [
          ./users/alarm/home.nix
        ];
      };
      # For machines that don't run NixOS.
      devbox = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {
          pkgs-unstable = pkgs-unstable_x86_64-linux;
        };
        modules = [
          ./users/devbox/home.nix
        ];
      };
    };
  };
}
