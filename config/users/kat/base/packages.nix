{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    tmate
    htop
    fd
    sd
    duc-cli
    bat
    exa-noman
    socat
    rsync
    wget
    ripgrep
    nixpkgs-fmt
    pv
    progress
    zstd
    file
    whois
    dnsutils
    neofetch
  ];
}
