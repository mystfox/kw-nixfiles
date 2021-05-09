rec {
  sources = import ./nix/sources.nix;
  pkgs = import ./pkgs { inherit sources; };
  modList = import ./lib/modules.nix;

  profiles = modList {
    modulesDir = ./profiles;
  };

  users = modList { modulesDir = ./users; };

  inherit (import ./lib/hosts.nix {
    inherit pkgs sources profiles users;
    inherit (deploy) target;
  })
    hosts targets;

  inherit (pkgs) lib;

  deploy = import ./lib/deploy.nix {
    inherit pkgs sources;
    inherit hosts targets;
  };
}
