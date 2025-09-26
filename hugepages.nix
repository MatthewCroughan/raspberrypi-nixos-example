{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [
    "hugepagesz=1GB"
    "default_hugepagesz=1G"
    "hugepages=16"
    "transparent_hugepages=never"
  ];

  systemd.mounts = [
    # disable mounting hugepages by systemd,
    # it doesn't know about 1G pagesize
    {
      where = "/dev/hugepages";
      enable = false;
    }
    {
      where = "/dev/hugepages/hugepages-1048576kB";
      enable = true;
      what = "hugetlbfs";
      type = "hugetlbfs";
      options = "pagesize=1G";
      requiredBy = [ "basic.target" ];
    }
  ];

  environment.etc."tmpfiles.d/thp.conf".text = ''
    w /sys/kernel/mm/transparent_hugepage/enabled         - - - - never
  '';

  boot.kernel.sysctl = {
    "vm.nr_hugepages" = lib.mkForce 16;
  };
}

