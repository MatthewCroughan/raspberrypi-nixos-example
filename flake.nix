{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, nixpkgs, nixos-hardware }: rec {
    images = let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in {
      pi4 = self.nixosConfigurations.pi4.config.system.build.image;
      pi3 = self.nixosConfigurations.pi3.config.system.build.image.overrideAttrs {
        postFixup = ''
          ${pkgs.gptfdisk}/bin/sgdisk --hybrid 1:EE $out/image.raw
          echo -e "M\nt\n1\n0b\nw\nr\nw\n" | ${pkgs.util-linux}/bin/fdisk $out/image.raw
        '';
      };

    };
    packages.x86_64-linux.pi-image = images.pi4;
    packages.aarch64-linux.pi-image = images.pi4;
    packages.x86_64-linux.pi3-image = images.pi3;
    packages.aarch64-linux.pi3-image = images.pi3;
    nixosConfigurations = {
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

