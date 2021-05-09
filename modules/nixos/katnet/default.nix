{ config, hosts, lib, pkgs, ... }:

with lib;

let cfg = config.katnet;
in
{
  options.katnet = {
    public.tcp.ports = mkOption {
      type = types.listOf types.port;
      default = [ ];
    };
    public.udp.ports = mkOption {
      type = types.listOf types.port;
      default = [ ];
    };
    private.tcp.ports = mkOption {
      type = types.listOf types.port;
      default = [ ];
    };
    private.udp.ports = mkOption {
      type = types.listOf types.port;
      default = [ ];
    };

    public.tcp.ranges = mkOption {
      type = types.listOf (types.attrsOf types.port);
      default = [ ];
    };
    public.udp.ranges = mkOption {
      type = types.listOf (types.attrsOf types.port);
      default = [ ];
    };
    private.tcp.ranges = mkOption {
      type = types.listOf (types.attrsOf types.port);
      default = [ ];
    };
    private.udp.ranges = mkOption {
      type = types.listOf (types.attrsOf types.port);
      default = [ ];
    };

    public.interfaces = mkOption {
      type = types.listOf types.str;
      description = "Public firewall interfaces";
      default = [ ];
    };
    private.interfaces = mkOption {
      type = types.listOf types.str;
      description = "Private firewall interfaces";
      default = [ ];
    };
  };

  config = {
    networking.firewall.interfaces =
      let
        fwTypes = {
          ports = "Ports";
          ranges = "PortRanges";
        };

        interfaceDef = visibility:
          listToAttrs (flatten (mapAttrsToList
            (type: typeString:
              map
                (proto: {
                  name = "allowed${toUpper proto}${typeString}";
                  value = cfg.${visibility}.${proto}.${type};
                }) [ "tcp" "udp" ])
            fwTypes));

        interfaces = visibility:
          listToAttrs
            (map (interface: nameValuePair interface (interfaceDef visibility))
              cfg.${visibility}.interfaces);
      in
      mkMerge (map (visibility: interfaces visibility) [ "public" "private" ]);
  };
}
