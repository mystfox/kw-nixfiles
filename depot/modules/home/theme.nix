{ config, lib, ... }:

/*
This module:
  * provides a central way to change the font my system uses.
*/

with lib;

let cfg = config.kw; in {
  options.kw = {
    wallpapers = mkOption {
      type = types.nullOr (types.listOf types.path);
      default = [ ../../users/kat/sway/wallpapers/left.jpg ../../users/kat/sway/wallpapers/main.png ../../users/kat/sway/wallpapers/right.jpg ];
    };

    font = {
      name = mkOption {
        type = types.str;
        default = "Cozette";
      };
      size = mkOption {
        type = types.float;
        default = 9.0;
      };
      size_css = mkOption {
        type = types.str;
        default = "${toString (cfg.font.size + 3)}px";
      };
    };
  };
}