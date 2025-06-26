{ config, pkgs, lib, ... }:

let
  waybarConfig = ''
    {
      "layer": "top",
      "position": "top",
      "modules-left": ["sway/workspaces", "sway/mode"],
      "modules-center": ["clock"],
      "modules-right": ["tray", "network", "temperature", "pulseaudio", "cpu", "memory", "battery"],
      "tray": { "icon-size": 16, "spacing": 10 },
      "network": {
        "interface": "wlo1",
        "format-wifi": " {signalStrength}%",
        "format-ethernet": " {ifname}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip": true,
        "on-click": "~/.config/waybar/scripts/network-connect.sh"
      },
      "temperature": {
        "format": "{}",
        "exec": "/home/ryu/check_temperature.sh",
        "tooltip": true
      },
      "pulseaudio": { "format": " {volume}%", "tooltip": true },
      "cpu": { "format": "{usage}%" },
      "memory": { "format": "{used}MB / {total}MB" }
    }
  '';
in {
  home.username = "ryu";
  home.homeDirectory = "/home/ryu";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    alacritty waybar swaylock git vim zsh
    jetbrains-mono nerd-fonts.jetbrains-mono
    papirus-icon-theme catppuccin-gtk hyprpaper
    networkmanagerapplet wofi pulseaudio grim slurp gimp
  ];

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -al";
      gs = "git status";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, alacritty"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod SHIFT, E, exit"
        "$mod, D, exec, wofi --show drun"
        "$mod, S, exec, bash -c 'TMP_SCREENSHOT=/home/ryu/Pictures/screenshot-$(date +%s).png; grim -g \"$(slurp)\" \"$TMP_SCREENSHOT\" && gimp \"$TMP_SCREENSHOT\"'"
        "$mod, L, exec, librewolf"
        "$mod, M, exec, steam"
      ];
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        "waybar"
        "hyprpaper"
      ];
      monitor = [ ",preferred,auto,1" ];
      env = [ "XCURSOR_SIZE,24" ];
      input = {
        kb_layout = "ch";
        kb_variant = "de";
        follow_mouse = 1;
      };
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(ff00ffaa)";
        "col.inactive_border" = "rgba(1a1a1aaa)";
      };
    };
  };

  programs.waybar.enable = true;
  home.file.".config/waybar/config".text = waybarConfig;

  # Updated random wallpaper script
  home.file.".config/hypr/random-wallpaper.sh" = {
    text = ''
      #!/usr/bin/env bash

      WALLPAPER_DIR="$HOME/Pictures/walls"
      MONITOR="eDP-1"

      WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

      hyprctl hyprpaper preload "$WALLPAPER"
      hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
    '';
    executable = true; 
  };

  # Hyprpaper daemon
  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "Hyprpaper daemon";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Wallpaper changer service
  systemd.user.services.hyprpaper-random = {
    Unit = {
      Description = "Set random wallpaper using Hyprpaper";
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.config/hypr/random-wallpaper.sh";
      Type = "oneshot";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Timer every 10 minutes
  systemd.user.timers.hyprpaper-random = {
    Unit = {
      Description = "Run wallpaper change every 10 minutes";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "10min";
      Unit = "hyprpaper-random.service";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Scripts
  home.file."scripts/network-status.sh".source = ./scripts/network-status.sh;
  home.file."scripts/network-connect.sh".source = ./scripts/network-connect.sh;

  home.activation.makeScriptsExecutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
    chmod +x $HOME/scripts/network-*.sh
  '';

  home.enableNixpkgsReleaseCheck = false;
}
