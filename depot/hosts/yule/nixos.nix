{ meta, config, pkgs, lib, ... }:

with lib;

{
  # Imports

  imports = with meta; [
    profiles.hardware.v330-14arr
    profiles.gui
    users.kat.guiFull
    services.netdata
    services.nginx
    services.node-exporter
    services.promtail
    services.restic
    services.zfs
  ];

  # File Systems and Swap

  boot.supportedFilesystems = singleton "zfs";

  fileSystems = {
    "/" = {
      device = "rpool/safe/root";
      fsType = "zfs";
    };
    "/home" = {
      device = "rpool/safe/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2552-18F2";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/87ff4f68-cc00-494e-8eba-050469c3bf03"; }];

  # Bootloader

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking

  networking = {
    hostId = "dddbb888";
    hostName = "yule";
    useDHCP = false;
    wireless.interfaces = singleton "wlp2s0";
    interfaces = {
      enp1s0.useDHCP = true;
      wlp2s0.useDHCP = true;
    };
  };

  # Firewall

  kw.fw = {
    public.interfaces = [ "enp1s0" "wlp2s0" ];
    private.interfaces = singleton "yggdrasil";
  };

  # Yggdrasil

  network.yggdrasil = {
    enable = true;
    pubkey = "9779fd6b5bdba6b9e0f53c96e141f4b11ce5ef749d1b9e77a759a3fdbd33a653";
    # if server, enable this and set endpoint:
    listen.enable = false;
    listen.endpoints = [ "tcp://0.0.0.0:0" ];
  };

  # State

  system.stateVersion = "20.09";
}

