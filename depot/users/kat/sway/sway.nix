{ config, pkgs, lib, witch, ... }:

let
  base16 = lib.mapAttrs' (k: v: lib.nameValuePair k "#${v.hex.rgb}")
    config.lib.arc.base16.schemeForAlias.default;
  footwrap = pkgs.writeShellScriptBin "footwrap" ''
    exec foot "$2"
  '';
in
{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    WLR_DRM_DEVICES="/dev/dri/card0";
  };

  home.file = {
    ".xkb/symbols/us_gbp_map".text = ''
default partial alphanumeric_keys
xkb_symbols "basic" {
	include "us(altgr-intl)"
	include "level3(caps_switch)"
	name[Group1] = "English (US, international with pound sign)";
        key <AD03> { [ e, E, EuroSign, cent ] };
        key <AE03> { [ 3, numbersign, sterling] };
};
    '';
  };

  xdg.configFile."wofi/wofi.css".text = ''
    #scroll, #input {
      background: ${base16.base01};
    }

    window {
      font-family: ${config.kw.font.name};
      background: ${lib.hextorgba base16.base00 0.75};
      border-radius: 1em;
      font-size: ${config.kw.font.size_css};
      color: ${base16.base07};
    }

    #outer-box {
      margin: 1em;
    }

    #scroll {
      border: 1px solid ${base16.base03};
    }

    #input {
      border: 1px solid ${base16.base0C};
      margin: 1em;
      background: ${base16.base02};
      color: ${base16.base04};
    }

    #entry {
      border-bottom: 1px dashed ${base16.base04};
      padding: .75em;
    }

    #entry:selected {
      background-color: ${base16.base0D};
    }
  '';

  kw.wallpapers = [ ./wallpapers/left.jpg ./wallpapers/main.png ./wallpapers/right.jpg ];

  home.packages = with pkgs; [ grim slurp wl-clipboard jq quintom-cursor-theme gsettings-desktop-schemas glib wofi ];

  services.i3gopher = { enable = true; };

  programs.zsh.profileExtra = ''
    # If running from tty1 start sway
    if [ "$(tty)" = "/dev/tty1" ]; then
      systemctl --user unset-environment \
        SWAYSOCK \
        I3SOCK \
        WAYLAND_DISPLAY \
        DISPLAY \
        IN_NIX_SHELL \
        __HM_SESS_VARS_SOURCED \
        GPG_TTY \
        NIX_PATH \
        SHLVL
      exec env --unset=SHLVL systemd-cat -t sway -- sway
    fi
  '';

  wayland.windowManager.sway =
    let
      cfg = config.wayland.windowManager.sway.config;
      bindsym = k: v: "bindsym ${k} ${v}";
      bindWorkspace = key: workspace: {
        "${cfg.modifier}+${key}" = "workspace number ${workspace}";
        "${cfg.modifier}+shift+${key}" =
          "move container to workspace number ${workspace}";
      };
      workspaceBindings = map (v: bindWorkspace v "${v}:${v}") [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
      ] ++ [ (bindWorkspace "0" "10:10") ]
      ++ lib.imap1 (i: v: bindWorkspace v "${toString (10 + i)}:${v}") [
        "F1"
        "F2"
        "F3"
        "F4"
        "F5"
        "F6"
        "F7"
        "F8"
        "F9"
        "F10"
        "F11"
        "F12"
      ];
      workspaceBindings' = map (lib.mapAttrsToList bindsym) workspaceBindings;
      workspaceBindingsStr =
        lib.concatStringsSep "\n" (lib.flatten workspaceBindings');
    in
    {
      enable = true;
      config =
        let
          dmenu = "${pkgs.wofi}/bin/wofi -idbt ${footwrap}/bin/footwrap -s ~/.config/wofi/wofi.css -p '' -W 25%";
        in
        {
          bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];

          input = {
            "*" = {
              xkb_layout = "us_gbp_map";
              xkb_options = "compose:rctrl,ctrl:nocaps";
            };
          };
          fonts = {
            names = [ config.kw.font.name ];
            style = "Medium";
            size = config.kw.font.size;
            };
          terminal = "${pkgs.foot}/bin/foot";
          # TODO: replace with wofi
          menu =
            "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --no-generic --dmenu=\"${dmenu}\" --term='${footwrap}/bin/footwrap'";
          modifier = "Mod4";

          assigns = { "12:F2" = [{ class = "screenstub"; }]; };
          startup = [
            {
              command = "gsettings set org.gnome.desktop.interface cursor-theme 'Quintom_Snow'";
            }
            {
              command = "systemctl --user restart mako";
              always = true;
            }
            {
              command = "systemctl --user restart konawall.service";
              always = true;
            }
          ];

          window = {
            border = 1;
            titlebar = false;
          };

          floating = {
            border = 1;
            titlebar = false;
          };

          keybindings = {
            "${cfg.modifier}+Return" = "exec ${cfg.terminal}";

            "${cfg.modifier}+Left" = "focus left";
            "${cfg.modifier}+Down" = "focus down";
            "${cfg.modifier}+Up" = "focus up";
            "${cfg.modifier}+Right" = "focus right";

            "${cfg.modifier}+Shift+Left" = "move left";
            "${cfg.modifier}+Shift+Down" = "move down";
            "${cfg.modifier}+Shift+Up" = "move up";
            "${cfg.modifier}+Shift+Right" = "move right";

            "${cfg.modifier}+Shift+space" = "floating toggle";
            "${cfg.modifier}+space" = "focus mode_toggle";

            "${cfg.modifier}+Tab" = "workspace back_and_forth";
            "${cfg.modifier}+Shift+Tab" =
              "exec ${config.services.i3gopher.focus-last}";
            "${cfg.modifier}+Ctrl+Left" = "workspace prev_on_output";
            "${cfg.modifier}+Ctrl+Right" = "workspace next_on_output";

            "XF86AudioRaiseVolume" =
              "exec pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') +5%";
            "XF86AudioLowerVolume" =
              "exec pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') -5%";
            "XF86AudioMute" =
              "exec pactl set-sink-mute $(pacmd list-sinks |awk '/* index:/{print $3}') toggle";
            "XF86AudioMicMute" =
              "exec pactl set-source-mute $(pacmd list-sources |awk '/* index:/{print $3}') toggle";
            "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5";
            "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5";

            "${cfg.modifier}+d" = "exec ${cfg.menu}";

            "${cfg.modifier}+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot --notify upload screen";
            "${cfg.modifier}+Shift+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot  --notify upload area";
            "${cfg.modifier}+Mod1+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot --notify upload window";
            "${cfg.modifier}+Control+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot --notify upload output";

            "Print" = "exec ${pkgs.kat-scrot}/bin/kat-scrot --notify copys screen";
            "Shift+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot  --notify copys area";
            "Mod1+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot --notify copys window";
            "Control+Print" =
              "exec ${pkgs.kat-scrot}/bin/kat-scrot --notify copys output";

            "${cfg.modifier}+i" = "move workspace to output left";
            "${cfg.modifier}+o" = "move workspace to output right";
            "${cfg.modifier}+b" = "splith";
            "${cfg.modifier}+v" = "splitv";
            "${cfg.modifier}+s" = "layout stacking";
            "${cfg.modifier}+w" = "layout tabbed";
            "${cfg.modifier}+e" = "layout toggle split";
            "${cfg.modifier}+f" = "fullscreen";

            "${cfg.modifier}+Shift+q" = "kill";
            "${cfg.modifier}+Shift+c" = "reload";

            "${cfg.modifier}+r" = "mode resize";
            "${cfg.modifier}+Delete" = ''
                mode "System (l) lock, (e) logout, (s) suspend, (h) hibernate, (r) reboot, (Shift+s) shutdown"'';
          };

          colors = {
            focused = {
              border = base16.base0D;
              background = base16.base0D;
              text = base16.base07;
              indicator = base16.base0D;
              childBorder = base16.base0D;
            };
            focusedInactive = {
              border = base16.base04;
              background = base16.base04;
              text = base16.base00;
              indicator = base16.base04;
              childBorder = base16.base04;
            };
            unfocused = {
              border = base16.base02;
              background = base16.base02;
              text = base16.base06;
              indicator = base16.base02;
              childBorder = base16.base02;
            };
            urgent = {
              border = base16.base08;
              background = base16.base08;
              text = base16.base00;
              indicator = base16.base08;
              childBorder = base16.base08;
            };
          };
        };
      wrapperFeatures.gtk = true;
      extraConfig = ''
        hide_edge_borders smart_no_gaps
        smart_borders no_gaps
        title_align center
        seat seat0 xcursor_theme Quintom_Snow 20
        workspace_auto_back_and_forth yes
        set $mode_gaps Gaps: (o) outer, (i) inner
        set $mode_gaps_outer Outer Gaps: +|-|0 (local), Shift + +|-|0 (global)
        set $mode_gaps_inner Inner Gaps: +|-|0 (local), Shift + +|-|0 (global)
        bindsym ${cfg.modifier}+Shift+g mode "$mode_gaps"

        mode "$mode_gaps" {
          bindsym o      mode "$mode_gaps_outer"
          bindsym i      mode "$mode_gaps_inner"
          bindsym Return mode "default"
          bindsym Escape mode "default"
        }

        mode "$mode_gaps_inner" {
          bindsym equal  gaps inner current plus 5
          bindsym minus gaps inner current minus 5
          bindsym 0     gaps inner current set 0

          bindsym plus  gaps inner all plus 5
          bindsym Shift+minus gaps inner all minus 5
          bindsym Shift+0     gaps inner all set 0

          bindsym Return mode "default"
          bindsym Escape mode "default"
        }

        mode "$mode_gaps_outer" {
          bindsym equal  gaps outer current plus 5
          bindsym minus gaps outer current minus 5
          bindsym 0     gaps outer current set 0

          bindsym plus  gaps outer all plus 5
          bindsym Shift+minus gaps outer all minus 5
          bindsym Shift+0     gaps outer all set 0

          bindsym Return mode "default"
          bindsym Escape mode "default"
        }
        ${workspaceBindingsStr}
      '';
    };

}