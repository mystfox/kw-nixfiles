{ config, lib, pkgs, tf, ... }:

{
  kw.secrets = [
    "gitea-mail-pass"
  ];

  secrets.files.gitea-mail-passfile = {
    text = ''
      ${tf.variables.gitea-mail-pass.ref};
    '';
    owner = "gitea";
    group = "gitea";
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "gitea" ];
    ensureUsers = [{
      name = "gitea";
      ensurePermissions."DATABASE gitea" = "ALL PRIVILEGES";
    }];
  };

  services.gitea = {
    enable = true;
    disableRegistration = true;
    domain = "git.${config.network.dns.domain}";
    rootUrl = "https://git.${config.network.dns.domain}";
    httpAddress = "127.0.0.1";
    appName = "kittywitch git";
    ssh = { clonePort = 62954; };
    database = {
      type = "postgres";
      name = "gitea";
      user = "gitea";
    };
    mailerPasswordFile = config.secrets.files.gitea-mail-passfile.path;
    settings = {
      security = { DISABLE_GIT_HOOKS = false; };
      api = { ENABLE_SWAGGER = true; };
      mailer = {
        ENABLED = true;
        SUBJECT = "%(APP_NAME)s";
        HOST = "athame.kittywit.ch:465";
        USER = "gitea@kittywit.ch";
        #SEND_AS_PLAIN_TEXT = true;
        USE_SENDMAIL = false;
        FROM = "\"kittywitch git\" <gitea@${config.network.dns.domain}>";
      };
      service = {
        NO_REPLY_ADDRESS = "kittywit.ch";
        REGISTER_EMAIL_CONFIRM = true;
        ENABLE_NOTIFY_MAIL = true;
      };
      ui = {
        THEMES = "pitchblack,gitea,arc-green";
        DEFAULT_THEME = "pitchblack";
        THEME_COLOR_META_TAG = "#222222";
      };
    };
  };

  systemd.services.gitea.serviceConfig.ExecStartPre = [
    "${pkgs.coreutils}/bin/ln -sfT ${pkgs.runCommand "gitea-public" {
    } ''
      ${pkgs.coreutils}/bin/mkdir -p $out/{css,img}
      ${pkgs.coreutils}/bin/cp ${pkgs.fetchFromGitHub {
        owner = "iamdoubz";
        repo = "Gitea-Pitch-Black";
        rev = "38a10947254e46a0a3c1fb90c617d913d6fe63b9";
        sha256 = "1zpmjv0h4k9nf52yaj22zyfabhv83n79f6cj6kfm5s685b2s1348";
      }}/theme-pitchblack.css $out/css
      ${pkgs.coreutils}/bin/cp -r ${./public}/* $out/
    ''} /var/lib/gitea/custom/public"
    "${pkgs.coreutils}/bin/ln -sfT ${./templates} /var/lib/gitea/custom/templates"
  ];

  services.nginx.virtualHosts."git.${config.network.dns.domain}" = {
    enableACME = true;
    forceSSL = true;
    locations = { "/".proxyPass = "http://127.0.0.1:3000"; };
  };

  deploy.tf.dns.records.services_gitea = {
    tld = config.network.dns.tld;
    domain = "git";
    cname.target = "${config.networking.hostName}.${config.network.dns.tld}";
  };
}