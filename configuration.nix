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
  boot.kernelParams = [ "cma=256M" "transparent_hugepage=always" "mitigations=off" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs; [
    vim
    waypipe
    librewolf
    pavucontrol
    pwvucontrol
    coppwr
    git
    wsjtx
    jtdx
    direwolf
    alsa-utils
    fldigi
    (js8call.overrideAttrs (old: {
       buildInputs = old.buildInputs ++ [ pkgs.pipewire pkgs.alsa-lib ];
       runtimeDependencies = [
         alsa-lib
         fftw
         pipewire
       ];
      # Needed for libraries that get dlopen'd
       env.NIX_LDFLAGS = toString [
         "-lpipewire-0.3"
         "-lasound"
         "-lfftw3"
         "-lfftw3_threads"
       ];

    }))
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
