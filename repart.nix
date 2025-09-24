{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
  configTxt = pkgs.writeText "config.txt" ''
    [pi4]
    kernel=u-boot.bin
    enable_gic=1
    armstub=armstub8-gic.bin
    disable_overscan=1
    arm_boost=1

    [all]
    arm_64bit=1
    enable_uart=1
    avoid_warnings=1
  '';
in
{
  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  systemd.repart.enable = true;
  systemd.repart.partitions."01-root".Type = "root";

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.root = "gpt-auto";
  boot.initrd.supportedFilesystems.ext4 = true;

  boot.loader = {
    generic-extlinux-compatible.enable = lib.mkForce false;
    grub.enable = lib.mkForce false;
  };

  hardware.deviceTree.enable = true;
  hardware.deviceTree.name = "broadcom/bcm2711-rpi-4-b.dtb";

  image.repart = {
    name = "image";
    compression.enable = true;
    partitions = {
      "01-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
          "/u-boot.bin".source = "${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin";
          "/armstub8-gic.bin".source = "${pkgs.raspberrypi-armstubs}/armstub8-gic.bin";
          "/config.txt".source = configTxt;
          "/".source = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "ESP";
          SizeMinBytes = "512M";
        };
      };
      "02-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Label = "nixos";
          Minimize = "guess";
          GrowFileSystem = true;
        };
      };
    };
  };
}

