{ config, lib, pkgs, profiles, users, tf, ... }:

with lib;

{
  # Imports

  imports = [
    profiles.hardware.rm-310
    profiles.gui
    users.kat.guiFull
    ./nixos/jellyfin.nix
    ./nixos/virtualhosts.nix
    ./nixos/transmission.nix
    ../../services/node-exporter.nix
    ../../services/promtail.nix
    ../../services/netdata.nix
    ../../services/nginx.nix
    ../../services/zfs.nix
  ];

  # File Systems and Swap

  boot.supportedFilesystems = singleton "zfs";

  fileSystems = {
    "/" = {
      device = "zroot/safe/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "zroot/local/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "zroot/safe/home";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/44CC-7137";
      fsType = "vfat";
    };
    "/boot-fallback" = {
      device = "/dev/disk/by-uuid/4520-4E5F";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/682df001-bad8-4d94-a86b-9068ce5eee4c"; }
    { device = "/dev/disk/by-uuid/1ee2d322-235c-41de-b272-7ceded4e2624"; }
  ];

  # Bootloader

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      mirroredBoots = [
        {
          devices = [ "/dev/disk/by-uuid/4520-4E5F" ];
          path = "/boot-fallback";
        }
      ];
    };
  };

  # Networking

  networking = {
    hostName = "beltane";
    hostId = "3ef9a419";
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  # Firewall

  kw.fw.private.interfaces = singleton "yggdrasil";
  kw.fw.public.interfaces = singleton "eno1";

  # Yggdrasil

  network.yggdrasil = {
    enable = true;
    pubkey = "d3e488574367056d3ae809b678f799c29ebfd5c7151bb1f4051775b3953e5f52";
    # if server, enable this and set endpoint:
    listen.enable = false;
    listen.endpoints = [ "tcp://0.0.0.0:0" ];
  };

  # State

  system.stateVersion = "21.05";

}
