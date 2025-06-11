{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Required for webcord.
    nixpkgs-electron-32.url = "github:NixOS/nixpkgs/782740762fb281404740b6b7084d356c3dab1173";

    # required to match on a specific version of Go for AKS dev setup.
    nixpkgs-msft-go.url = "github:NixOS/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";

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
      url = "github:nix-community/home-manager/release-25.05";
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
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-msft-go,
    nix-darwin,
    apple-silicon,
    nixos-hardware,
    home-manager,
    ghostty,
    nixgl,
    ssh-agent-switcher,
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
      asahi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs apple-silicon ghostty;
        };
        modules = [
          ./hosts/asahi/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jmug = import ./hosts/asahi/home.nix;
          }
        ];
      };
      devbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
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
    };

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations = {
      "macbook" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs ghostty self;
        };
        modules = [
          ./hosts/macbook/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.uagm.imports = [ ./hosts/macbook/home.nix ];
          }
        ];
      };
    };

    homeConfigurations = {
      alarm = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-linux";
        modules = [
          ./users/alarm/home.nix
        ];
      };
      msftdevbox = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {
          pkgs-msft-go = nixpkgs-msft-go.legacyPackages."x86_64-linux";
          pkgs-unstable = nixpkgs-unstable.legacyPackages."x86_64-linux";
        };
        modules = [
          ./users/msftdevbox/home.nix
        ];
      };
      nixlapmsft = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {
          inherit ghostty nixgl;
          pkgs-msft-go = nixpkgs-msft-go.legacyPackages."x86_64-linux";
          pkgs-unstable = nixpkgs-unstable.legacyPackages."x86_64-linux";
        };
        modules = [
          ./users/nixlapmsft/home.nix
        ];
      };
    };
  };
}
