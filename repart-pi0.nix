{
  lib,
  config,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
  configTxt = pkgs.writeText "config.txt" ''
    [pi0]
    kernel=u-boot.bin
    disable_overscan=1

    [all]
    enable_uart=1
    avoid_warnings=1
  '';
in
{
  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  boot.kernelPatches = [
    {
      name = "config-enable-zboot";
      patch = null;
      extraStructuredConfig = {
        EFI = lib.mkForce lib.kernel.yes;
        EFI_ZBOOT = lib.mkForce lib.kernel.yes;
        EFIVAR_FS = lib.mkForce lib.kernel.yes;
      };
    }
  ];

  hardware.enableRedistributableFirmware = true;
  boot.initrd.systemd.tpm2.enable = false;

  nixpkgs.overlays = [
    (self: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
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
  hardware.deviceTree.name = "bcm2835-rpi-zero-w.dtb";

  image.repart = {
    package = pkgs.buildPackages.systemd.overrideAttrs (old: {
      # https://github.com/systemd/systemd/issues/35591
      # https://github.com/util-linux/util-linux/issues/3353
      patches = old.patches or [] ++ [ ./0001-repart-Support-named-GPT-flags-in-libfdisk.patch ];
    });
    name = "image";
    compression.enable = false;
    partitions = {
      "01-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
          "/u-boot.bin".source = "${inputs.nixpkgs2411.legacyPackages.x86_64-linux.pkgsCross.raspberryPi.ubootRaspberryPiZero}/u-boot.bin";
          "/config.txt".source = configTxt;
          "/".source = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "ESP";
          SizeMinBytes = "512M";
          Flags = "0x4";
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

