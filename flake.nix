{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
  outputs = { self, nixpkgs, nixos-hardware }: rec {
    images = {
      pi = (self.nixosConfigurations.pi.extendModules {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          {
            disabledModules = [ "profiles/base.nix" ];
          }
        ];
      }).config.system.build.sdImage;
    };
    packages.x86_64-linux.pi-image = images.pi;
    packages.aarch64-linux.pi-image = images.pi;
    nixosConfigurations = {
      pi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
          ./configuration.nix
          ./base.nix
        ];
      };
    };
  };
}

