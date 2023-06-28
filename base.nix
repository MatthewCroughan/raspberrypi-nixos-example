{ pkgs, config, lib, ... }:
{
  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;
  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
  };

  sdImage = {
    firmwareSize = 256;
    populateFirmwareCommands = ''
      ${config.system.build.installBootLoader} ${config.system.build.toplevel} -d firmware
    '';
    populateRootCommands = ''
    '';
  };

   boot = {
     loader = {
       grub.enable = false;
       generic-extlinux-compatible.enable = lib.mkForce false;
       raspberryPi = {
         version = 3;
         enable = true;
         uboot.enable = false;
       };
     };
   };

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  nix.settings.experimental-features = lib.mkDefault "nix-command flakes";
}
