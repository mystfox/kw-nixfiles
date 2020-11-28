{ config, lib, pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome3.gvfs;
  };

  home-manager.users.kat = {
    home.packages = [
      pkgs.xfce.xfce4-terminal
      pkgs.xfce.thunar
      pkgs.xfce.orage
      pkgs.xfce.xfce4-battery-plugin
      pkgs.xfce.xfce4-sensors-plugin
      pkgs.xfce.xfce4-pulseaudio-plugin
      pkgs.xfce.xfce4-whiskermenu-plugin
      pkgs.xfce.xfce4-screenshooter
    ];
  };
}