{ pkgs, config, lib, ... }:
{
  environment.systemPackages = with pkgs; [ vim git ];
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
    interfaces.wlan0 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = "192.168.8.207";
        prefixLength = 24;
      } ];
    };
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        HLS.psk = "tapeheads";
      };
    };
  };
}
