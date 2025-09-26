{ pkgs, lib, ... }:
{
  imports = [
    ./minimize.nix
  ];
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
    pulse.enable = true;
  };
  environment.sessionVariables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/broadcom_icd.aarch64.json";
  environment.sessionVariables.GSK_RENDERER = "vulkan";
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      vulkan-tools
    ];
  };
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };
  boot.kernelParams = [ "cma=256M" "transparent_hugepage=always" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs; [
    vim
    librewolf
    git
    wsjtx
    jtdx
    direwolf
    fldigi
    js8call
  ];
  services.openssh.enable = true;
  networking.hostName = "pi";
  users = {
    users.default = {
      password = "default";
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" "input" "video" "audio" ];
    };
  };
  networking = {
    interfaces."wlan0".useDHCP = true;
    networkmanager.wifi.backend = "iwd";
  };
  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];
  services.udisks2.enable = lib.mkForce false;
}
