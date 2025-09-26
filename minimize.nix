{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];
  boot.loader.grub.enable = false;
  environment.defaultPackages = [ ];
  programs.less.lessopen = null;
  programs.command-not-found.enable = false;
  boot.enableContainers = false;
  system.disableInstallerTools = false;
  system.etc.overlay.enable = false;
#  systemd.sysusers.enable = true;
}
