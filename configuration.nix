{ pkgs, lib, ... }:
{
  imports = [
    ./minimize.nix
    ./musl.nix
  ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs; [ vim ];
  services.openssh.enable = true;
  networking.hostName = "pi";
  users = {
    users.default = {
      password = "default";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
  networking = {
    interfaces."wlan0".useDHCP = true;
    #wireless = {
    #  interfaces = [ "wlan0" ];
    #  enable = true;
    #  networks = {
    #    DoESLiverpool.psk = "decafbad00";
    #  };
    #};
  };
  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-browser-connector.enable = lib.mkForce false;
  services.gnome.core-apps.enable = lib.mkForce false;
  services.gnome.core-developer-tools.enable = lib.mkForce false;
  services.gnome.games.enable = lib.mkForce false;
  services.gnome.gnome-online-accounts.enable = lib.mkForce false;
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  services.gnome.gnome-initial-setup.enable = lib.mkForce false;
  services.gnome.gnome-remote-desktop.enable = lib.mkForce false;
  services.gnome.gnome-user-share.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;

services.gnome.at-spi2-core.enable = lib.mkForce false;
services.gnome.core-os-services.enable = lib.mkForce false;
services.gnome.core-shell.enable = lib.mkForce false;
services.gnome.core-utilities.enable = lib.mkForce false;
services.gnome.evolution-data-server.enable = lib.mkForce false;
services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
services.gnome.glib-networking.enable = lib.mkForce false;
services.gnome.localsearch.enable = lib.mkForce false;
services.gnome.rygel.enable = lib.mkForce false;
services.gnome.sushi.enable = lib.mkForce false;
services.gnome.tinysparql.enable = lib.mkForce false;
services.gnome.tracker.enable = lib.mkForce false;
services.gnome.tracker-miners.enable = lib.mkForce false;
services.gnome.gnome-settings-daemon.enable = lib.mkForce false;
services.geoclue2.enable = lib.mkForce false;
programs.gnome-disks.enable = lib.mkForce false;

  environment.gnome.excludePackages = with pkgs.gnome; [
    baobab      # disk usage analyzer
    cheese      # photo booth
    eog         # image viewer
    epiphany    # web browser
    gedit       # text editor
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    evince      # document viewer
    file-roller # archive manager
    geary       # email client
    seahorse    # password manager

    # these should be self explanatory
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-photos gnome-screenshot
    gnome-system-monitor gnome-weather gnome-disk-utility pkgs.gnome-connections
  ];

system.fsPackages = lib.mkForce [];

services.gvfs.enable = false;

}
