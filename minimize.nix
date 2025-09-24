{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/perlless.nix"
  ];
  boot.loader.grub.enable = false;
  environment.defaultPackages = [ ];
  programs.less.lessopen = null;
  programs.command-not-found.enable = false;
  boot.enableContainers = false;
  system.disableInstallerTools = true;
  system.etc.overlay.enable = true;
#  systemd.sysusers.enable = true;
}
