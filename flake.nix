{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, nixpkgs, nixpkgs2411, nixos-hardware }@inputs: rec {
    images = let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in {
      pi4 = self.nixosConfigurations.pi4.config.system.build.image;
      pi3 = self.nixosConfigurations.pi3.config.system.build.image.overrideAttrs {
        preInstall = ''
          ${pkgs.gptfdisk}/bin/sgdisk --hybrid 1:EE ${self.nixosConfigurations.pi3.config.image.repart.imageFileBasename}.raw
          echo -e "M\nt\n1\n0b\nw\nr\nw\n" | ${pkgs.util-linux}/bin/fdisk ${self.nixosConfigurations.pi3.config.image.repart.imageFileBasename}.raw
        '';
      };
      pi-zero-2-w = self.nixosConfigurations.pi-zero-2-w.config.system.build.image.overrideAttrs {
        preInstall = ''
          ${pkgs.gptfdisk}/bin/sgdisk --hybrid 1:EE ${self.nixosConfigurations.pi-zero-2-w.config.image.repart.imageFileBasename}.raw
          echo -e "M\nt\n1\n0b\nw\nr\nw\n" | ${pkgs.util-linux}/bin/fdisk ${self.nixosConfigurations.pi-zero-2-w.config.image.repart.imageFileBasename}.raw
        '';
      };
      pi0 = self.nixosConfigurations.pi0.config.system.build.image.overrideAttrs {
        preInstall = ''
          ${pkgs.gptfdisk}/bin/sgdisk --hybrid 1:EE ${self.nixosConfigurations.pi0.config.image.repart.imageFileBasename}.raw
          echo -e "M\nt\n1\n0b\nw\nr\nw\n" | ${pkgs.util-linux}/bin/fdisk ${self.nixosConfigurations.pi0.config.image.repart.imageFileBasename}.raw
        '';
      };
    };
    packages.x86_64-linux.pi4-image = images.pi4;
    packages.aarch64-linux.pi4-image = images.pi4;
    packages.x86_64-linux.pi3-image = images.pi3;
    packages.aarch64-linux.pi3-image = images.pi3;
    packages.x86_64-linux.pi-zero-2-w-image = images.pi-zero-2-w;
    packages.aarch64-linux.pi-zero-2-w-image = images.pi-zero-2-w;
    packages.x86_64-linux.pi0-image = images.pi0;
    packages.aarch64-linux.pi0-image = images.pi0;
    nixosConfigurations = {
      pi0 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          {
            nixpkgs.crossSystem = {
              system = "armv6l-linux";
            };
          }
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./repart-pi0.nix
          ./configuration.nix
        ];
      };
      pi-zero-2-w = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-3
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./repart-pi-zero-2-w.nix
          ./configuration.nix
        ];
      };
      pi3 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-3
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./repart-pi3.nix
          ./configuration.nix
        ];
      };
      pi4 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./repart.nix
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./configuration.nix
        ];
      };
    };
  };
}

