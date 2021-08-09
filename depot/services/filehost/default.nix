{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts = {
    "files.${config.kw.dns.domain}" = {
      root = "/var/www/files";
      enableACME = true;
      forceSSL = true;
    };
  };

  deploy.tf.dns.records.services_filehost = {
    tld = config.kw.dns.tld;
    domain = "files";
    cname.target = "${config.networking.hostName}.${config.kw.dns.tld}";
  };
}