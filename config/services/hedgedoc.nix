{ config, lib, tf, ... }: with lib;

{
  kw.secrets.variables = (mapListToAttrs
    (field:
      nameValuePair "hedgedoc-${field}" {
        path = "secrets/hedgedoc";
        inherit field;
      }) [ "secret" ]);

  secrets.files.hedgedoc-env = {
    text = ''
      CMD_OAUTH2_USER_PROFILE_URL=https://auth.${config.network.dns.domain}/auth/realms/kittywitch/protocol/openid-connect/userinfo
      CMD_OAUTH2_CLIENT_SECRET=${tf.variables.hedgedoc-secret.ref}
      CMD_OAUTH2_USER_PROFILE_USERNAME_ATTR=preferred_username
      CMD_OAUTH2_USER_PROFILE_DISPLAY_NAME_ATTR=name
      CMD_OAUTH2_USER_PROFILE_EMAIL_ATTR=email
      CMD_OAUTH2_PROVIDERNAME=Keycloak
      CMD_DOMAIN=md.kittywit.ch
    '';
    owner = "hedgedoc";
    group = "hedgedoc";
  };

  services.hedgedoc = {
    enable = true;
    configuration = {
      debug = true;
      path = "/run/hedgedoc/hedgedoc.sock";
      domain = "md.${config.network.dns.domain}";
      protocolUseSSL = true;
      allowFreeURL = true;
      email = false;
      allowEmailRegister = false;
      allowAnonymous = false;
      allowAnonymousEdits = true;
      imageUploadType = "filesystem";
      allowGravatar = true;
      db = {
        dialect = "postgres";
        host = "/run/postgresql";
      };
      oauth2 = {
        tokenURL = "https://auth.${config.network.dns.domain}/auth/realms/kittywitch/protocol/openid-connect/token";
        authorizationURL = "https://auth.${config.network.dns.domain}/auth/realms/kittywitch/protocol/openid-connect/auth";
        clientID = "hedgedoc";
        clientSecret = "";
      };
    };
    environmentFile = config.secrets.files.hedgedoc-env.path;
  };

  deploy.tf.dns.records.services_hedgedoc = {
    inherit (config.network.dns) zone;
    domain = "md";
    cname = { inherit (config.network.addresses.public) target; };
  };

  systemd.services.hedgedoc = {
    serviceConfig = {
      UMask = "0007";
      RuntimeDirectory = "hedgedoc";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "hedgedoc" ];
    ensureUsers = [
      {
        name = "hedgedoc";
        ensurePermissions."DATABASE hedgedoc" = "ALL PRIVILEGES";
      }
    ];
  };

  users.users.nginx.extraGroups = [ "hedgedoc" ];
  services.nginx.virtualHosts."md.${config.network.dns.domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://unix:/run/hedgedoc/hedgedoc.sock";
      proxyWebsockets = true;
    };
  };
}
