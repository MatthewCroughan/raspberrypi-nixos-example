{ pkgs, lib, config, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{
  imports = [
#    ./kmod-issue.nix # Failed to initialize kmod context: Not supported
#    ./super-minimal.nix
  ];
  nixpkgs.crossSystem = {
    config = "aarch64-unknown-linux-musl";
  };
  services.nscd.enableNsncd = false;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
  boot.bcache.enable = false;
  i18n.glibcLocales = pkgs.runCommandNoCC "neutered" { } "mkdir -p $out";
#  image.repart.partitions."20-esp".contents."/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = lib.mkForce  "${glibcPkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
  boot.uki.settings.UKI.Stub =
    "${glibcPkgs.systemd}/lib/systemd/boot/efi/linux${pkgs.stdenv.hostPlatform.efiArch}.efi.stub";
  boot.kernelPatches = [
    {
      name = "config-enable-zboot";
      patch = null;
      structuredExtraConfig = {
        EFI_ZBOOT = lib.mkForce lib.kernel.yes;
        KERNEL_ZSTD = lib.mkForce lib.kernel.yes;
        RD_ZSTD = lib.mkForce lib.kernel.yes;
      };
    }
  ];
  nixpkgs.overlays = [
    (self: super: {
      qemu = glibcPkgs.qemu;
    })
  ];
  environment.corePackages = with pkgs; [
    acl
    attr
    bashInteractive
    bzip2
    coreutils-full
    cpio
#    curl
#    diffutils
    findutils
    gawk
    getent
    getconf
    gnugrep
    gnupatch
    gnused
    gnutar
    gzip
    xz
    less
    libcap
    ncurses
    netcat
    mkpasswd
    procps
    su
    time
    util-linux
    which
    zstd
  ];
}

